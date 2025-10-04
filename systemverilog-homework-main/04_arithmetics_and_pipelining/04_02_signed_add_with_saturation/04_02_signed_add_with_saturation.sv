//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module add
(
  input  [3:0] a, b,
  output [3:0] sum
);

  assign sum = a + b;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module signed_add_with_saturation
(
  input  [3:0] a, b,
  output [3:0] sum
);

  // Task:
  //
  // Implement a module that adds two signed numbers with saturation.
  //
  // "Adding with saturation" means:
  //
  // When the result does not fit into 4 bits,
  // and the arguments are positive,
  // the sum should be set to the maximum positive number.
  //
  // When the result does not fit into 4 bits,
  // and the arguments are negative,
  // the sum should be set to the minimum negative number.

logic [3:0] sum1;

assign sum1 = a + b;
assign overflow = a[3] ^ b[3] ? 1'b0 : a[3] ^ sum1[3] ? 1'b1 : 1'b0;
assign sum = (overflow == 1'b0) ? sum1 : (sum1[3] == 1'b1) ? 4'b0111 : 4'b1000;

endmodule
