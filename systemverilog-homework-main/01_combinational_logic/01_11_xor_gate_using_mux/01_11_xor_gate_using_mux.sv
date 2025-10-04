//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module mux
(
  input  d0, d1,
  input  sel,
  output y
);

  assign y = sel ? d1 : d0;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module xor_gate_using_mux
(
    input  a,
    input  b,
    output o
);

  // Task:
  // Implement xor gate using instance(s) of mux,
  // constants 0 and 1, and wire connections

logic b_not;

  mux mux2(
	.d0(1'b1),
	.d1(1'b0),
	.sel(b),
	.y(b_not)
  );
  
   mux mux3(
	.d0(b),
	.d1(b_not),
	.sel(a),
	.y(o)
  );

endmodule
