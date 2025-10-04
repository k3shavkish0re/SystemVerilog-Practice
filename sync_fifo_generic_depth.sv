module sync_fifo #(
    parameter DEPTH = 6,
    parameter WIDTH = 8
)(
    input  logic clk,
    input  logic rst_n,
    input  logic wr_en,
    input  logic [WIDTH-1:0] data_in,
    input  logic rd_en,
    output logic [WIDTH-1:0] data_out,
    output logic full,
    output logic empty
);

    logic [$clog2(DEPTH)-1:0] wptr_d, rptr_d;
    logic [$clog2(DEPTH)-1:0] wptr_q, rptr_q;
    logic [$clog2(DEPTH):0] count_d, count_q; 

    logic [DEPTH-1:0][WIDTH-1:0] fifo;
    logic [WIDTH-1:0] data_out_r;

    assign wptr_d = (wr_en && !full)  ? ((wptr_q == DEPTH-1) ? '0 : wptr_q + 1) : wptr_q;
	
	//here we are reading only 8 bits thus rptr + 1
	//If we want to read 16 bits do rptr + 2, data_out_r <= {fifo[rptr+q + 1], fifo[rptr_q]}
    assign rptr_d = (rd_en && !empty) ? ((rptr_q == DEPTH-1) ? '0 : rptr_q + 1) : rptr_q;

    assign count_d = (wr_en && !rd_en && !full)  ? count_q + 1 :
                     (!wr_en && rd_en && !empty) ? count_q - 1 :
                     count_q;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            wptr_q   <= '0;
            rptr_q   <= '0;
            count_q  <= '0;
            data_out_r <= '0;
        end
        else begin
            wptr_q  <= wptr_d;
            rptr_q  <= rptr_d;
            count_q <= count_d;
            if (wr_en && !full)
                fifo[wptr_q] <= data_in;
            if (rd_en && !empty)
                data_out_r <= fifo[rptr_q];
        end
    end

    assign full  = (count_q == DEPTH);
    assign empty = (count_q == 0);
    assign data_out = data_out_r;

endmodule
