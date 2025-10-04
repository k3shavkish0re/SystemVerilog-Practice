//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module double_tokens
(
    input        clk,
    input        rst,
    input        a,
    output       b,
    output logic overflow
);
    // Task:
    // Implement a serial module that doubles each incoming token '1' two times.
    // The module should handle doubling for at least 200 tokens '1' arriving in a row.
    //
    // In case module detects more than 200 sequential tokens '1', it should assert
    // an overflow error. The overflow error should be sticky. Once the error is on,
    // the only way to clear it is by using the "rst" reset signal.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // a -> 10010011000110100001100100
    // b -> 11011011110111111001111110

logic [9:0] count_d;
logic [9:0] count_q;
logic overflow_d;

assign count_d = a && (count_q == '0) ? count_q + 2 : a && (count_q > '0)? count_q + 1 : ~a && (count_q > '0) ? count_q - 1 : count_q;
assign overflow_d = (count_q > 10'd399) ? 1'b1 : overflow; 

  always_ff @ (posedge clk)
    if (rst)
    begin
      count_q <= '0;
	  overflow <= '0;
    end
    else
    begin
      count_q <= count_d;
	  overflow <= overflow_d;
    end

assign b = (count_q > '0);

endmodule
