module lru_cache_4way #(
    parameter DEPTH       = 8,     // total number of cache lines
    parameter WAYS        = 4,     // associativity
    parameter TAG_BITS    = 31,
    parameter BLOCK_SIZE  = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic wr_en,
    input  logic rd_en,
    input  logic [31:0] addr,              // address = {tag, index}
    input  logic [BLOCK_SIZE-1:0] data_in,
    output logic [BLOCK_SIZE-1:0] data_out,
    output logic [BLOCK_SIZE-1:0] data_evicted,
    output logic                  data_evict_en
);

    // --------------------------------------------
    // Derived parameters
    // --------------------------------------------
    localparam NUM_SETS   = DEPTH / WAYS;
    localparam INDEX_BITS = $clog2(NUM_SETS);
    localparam WAY_BITS   = $clog2(WAYS);

    // --------------------------------------------
    // Cache line definition
    // --------------------------------------------
    typedef struct packed {
        logic [TAG_BITS-1:0]     tag;
        logic [BLOCK_SIZE-1:0]   value;
        logic                    valid;
        logic [WAY_BITS-1:0]     lru_counter;		//0 - most recently used, maximum counter value will get evicted
    } cache_line_t;

    cache_line_t cache [DEPTH-1:0];  // <-- flattened array

    // --------------------------------------------
    // Address breakdown
    // --------------------------------------------
    logic [TAG_BITS-1:0]   addr_tag;
    logic [INDEX_BITS-1:0] addr_index;
    assign addr_index = addr[0 +: INDEX_BITS];
    assign addr_tag   = addr[31 -: TAG_BITS];

    // --------------------------------------------
    // Internal combinational signals
    // --------------------------------------------
    logic hit;
    logic [WAY_BITS-1:0] hit_way;
    logic [WAY_BITS-1:0] lru_way_comb;
    logic [BLOCK_SIZE-1:0] data_out_comb;
    logic [BLOCK_SIZE-1:0] data_evicted_comb;
    logic data_evict_en_comb;

    integer i, j;

    // --------------------------------------------
    // Hit Detection
    // --------------------------------------------
    always_comb begin
        hit = 1'b0;
        hit_way = '0;
        for (i = 0; i < WAYS; i++) begin
            int idx = addr_index * WAYS + i;
            if (cache[idx].valid && cache[idx].tag == addr_tag) begin
                hit = 1'b1;
                hit_way = i[WAY_BITS-1:0];
            end
        end
    end

    // --------------------------------------------
    // LRU Way Selection
    // --------------------------------------------
    always_comb begin
        lru_way_comb = '0;
        for (i = 1; i < WAYS; i++) begin
            int idx_i = addr_index * WAYS + i;
            int idx_lru = addr_index * WAYS + lru_way_comb;
            if (cache[idx_i].lru_counter > cache[idx_lru].lru_counter)
                lru_way_comb = i;
        end
    end

    // --------------------------------------------
    // Output and Eviction Computation
    // --------------------------------------------
    always_comb begin
        data_out_comb      = '0;
        data_evicted_comb  = '0;
        data_evict_en_comb = 1'b0;

        if (wr_en) begin
            if (hit) begin
                int idx = addr_index * WAYS + hit_way;
                data_out_comb = cache[idx].value;
            end
            else begin
                int idx = addr_index * WAYS + lru_way_comb;
                if (cache[idx].valid) begin
                    data_evicted_comb  = cache[idx].value;
                    data_evict_en_comb = 1'b1;
                end
            end
        end
        else if (rd_en && hit) begin
            int idx = addr_index * WAYS + hit_way;
            data_out_comb = cache[idx].value;
        end
    end

    // --------------------------------------------
    // Sequential updates
    // --------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i++) begin
                cache[i].valid       <= 1'b0;
                cache[i].lru_counter <= i % WAYS;
                cache[i].tag         <= '0;
                cache[i].value       <= '0;
            end
            data_out      <= '0;
            data_evicted  <= '0;
            data_evict_en <= 1'b0;
        end
        else begin
            data_out      <= data_out_comb;
            data_evicted  <= data_evicted_comb;
            data_evict_en <= data_evict_en_comb;

            // ------------------ WRITE ------------------
            if (wr_en) begin
                if (hit) begin
                    int idx = addr_index * WAYS + hit_way;
                    cache[idx].value       <= data_in;
                    cache[idx].lru_counter <= '0;
                end
                else begin
                    int idx = addr_index * WAYS + lru_way_comb;
                    cache[idx].tag         <= addr_tag;
                    cache[idx].value       <= data_in;
                    cache[idx].valid       <= 1'b1;
                    cache[idx].lru_counter <= '0;
                end

                // update other ways’ LRU
                for (j = 0; j < WAYS; j++) begin
                    int idx = addr_index * WAYS + j;
                    if ((hit && j != hit_way) || (!hit && j != lru_way_comb))
                        cache[idx].lru_counter <= cache[idx].lru_counter + 1;
                end
            end

            // ------------------ READ ------------------
            else if (rd_en && hit) begin
                int idx_hit = addr_index * WAYS + hit_way;
                cache[idx_hit].lru_counter <= '0;
                for (j = 0; j < WAYS; j++) begin
                    int idx = addr_index * WAYS + j;
                    if (j != hit_way)
                        cache[idx].lru_counter <= cache[idx].lru_counter + 1;
                end
            end
        end
    end
endmodule
