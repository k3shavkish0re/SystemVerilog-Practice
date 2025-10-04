`timescale 1ns/10ps

// ======================= DUT ==========================
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

// ======================= Assertions + Coverage ==========================
module sync_fifo_check #(
    parameter WIDTH=8,
    parameter DEPTH=6
)(
    input logic clk,
    input logic rst_n,
    input logic wr_en,
    input logic [WIDTH-1:0] data_in,
    input logic rd_en,
    input logic [WIDTH-1:0] data_out,
    input logic full,
    input logic empty,

    // Internal signals from DUT
    input logic [$clog2(DEPTH)-1:0] wptr_q,
    input logic [$clog2(DEPTH)-1:0] rptr_q,
    input logic [$clog2(DEPTH):0] count_q
);

    // ---------- Assertions ----------
    property reset_assertion;
        !rst_n |-> (!full && !empty && count_q == 0);
    endproperty
    A1: assert property (reset_assertion)
        else $error("Reset assertion failed!");

    property full_empty;
        @(posedge clk) !(full && empty);
    endproperty
    A2: assert property (full_empty)
        else $error("Full and empty asserted together!");

    // ---- Internal Pointer and Counter Assertions ----
    property count_within_bounds;
        @(posedge clk) count_q <= DEPTH && count_q >= 0;
    endproperty
    A3: assert property (count_within_bounds)
        else $error("Count exceeded DEPTH or became negative!");

    property wptr_in_range;
        @(posedge clk) wptr_q < DEPTH;
    endproperty
    A4: assert property (wptr_in_range)
        else $error("Write pointer out of range!");

    property rptr_in_range;
        @(posedge clk) rptr_q < DEPTH;
    endproperty
    A5: assert property (rptr_in_range)
        else $error("Read pointer out of range!");

    property fifo_consistency;
        @(posedge clk) (full -> count_q == DEPTH) and (empty -> count_q == 0);
    endproperty
    A6: assert property (fifo_consistency)
        else $error("Full/empty inconsistent with count!");

    property pointer_wrap;
        @(posedge clk) disable iff(!rst_n)
        (wr_en && !full && wptr_q == DEPTH-1) |=> (wptr_q == 0);
    endproperty
    A7: assert property (pointer_wrap)
        else $error("Write pointer did not wrap correctly!");

    // ---------- Coverage ----------
    covergroup input_cg @(posedge clk);
        coverpoint wr_en { bins zero = {0}; bins one = {1}; }
        coverpoint data_in { bins low = {0}; bins mid = {[1:254]}; bins high = {255}; }
    endgroup

    covergroup output_cg @(posedge clk);
        coverpoint full { bins zero = {0}; bins one = {1}; }
        coverpoint empty { bins zero = {0}; bins one = {1}; }
        coverpoint rd_en { bins zero = {0}; bins one = {1}; }
        coverpoint data_out { bins low = {0}; bins mid = {[1:254]}; bins high = {255}; }
    endgroup

    input_cg  in_cov = new();
    output_cg out_cov = new();

endmodule

// ======================= Testbench / Top ==========================
module top;
    parameter WIDTH = 8;
    parameter DEPTH = 6;

    logic clk, rst_n, wr_en, rd_en;
    logic [WIDTH-1:0] data_in, data_out;
    logic full, empty;

    // DUT instantiation
    sync_fifo #(DEPTH, WIDTH) dut (
        .clk, .rst_n, .wr_en, .data_in, .rd_en, .data_out, .full, .empty
    );

    // ----------- Bind Checker -----------
    bind sync_fifo sync_fifo_check #(.WIDTH(WIDTH), .DEPTH(DEPTH))
        check_inst (
            .clk, .rst_n, .wr_en, .data_in, .rd_en, .data_out, .full, .empty,
            .wptr_q, .rptr_q, .count_q
        );

    // ----------- Clock -----------
    initial clk = 0;
    always #5 clk = ~clk;

    // ----------- Stimulus -----------
    initial begin
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        data_in = 0;
        #20 rst_n = 1;

        repeat (20) begin
            @(negedge clk);
            wr_en = $urandom_range(0,1);
            rd_en = $urandom_range(0,1);
            data_in = $urandom_range(0,255);
        end
        #50 $finish;
    end
endmodule
