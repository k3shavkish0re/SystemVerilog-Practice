//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module halve_tokens
(
    input  clk,
    input  rst,
    input  a,
    output b
);
    // Task:
    // Implement a serial module that reduces amount of incoming '1' tokens by half.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 110_011_101_000_1111
    // b -> 010_001_001_000_0101

logic count_d;
logic count_q;

assign count_d = ~count_q & a ? count_q + 1 : count_q & a ? 1'b0 : count_q;

  always_ff @ (posedge clk)
    if (rst)
    begin
      count_q <= '0;
    end
    else
    begin
      count_q <= count_d;
    end

assign b = count_q & a;


endmodule
