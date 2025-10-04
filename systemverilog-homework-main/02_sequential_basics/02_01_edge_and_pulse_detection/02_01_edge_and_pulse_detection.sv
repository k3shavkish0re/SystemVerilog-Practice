//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module posedge_detector (input clk, rst, a, output detected);

  logic a_r;

  // Note:
  // The a_r flip-flop input value d propogates to the output q
  // only on the next clock cycle.

  always_ff @ (posedge clk)
    if (rst)
      a_r <= '0;
    else
      a_r <= a;

  assign detected = ~ a_r & a;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module one_cycle_pulse_detector (input clk, rst, a, output detected);

  // Task:
  // Create an one cycle pulse (010) detector.
  //
  // Note:
  // See the testbench for the output format ($display task).

logic posedge_out;
logic posedge_out_q;
logic negedge_detected;
logic a_r;

assign negedge_detected = !a & a_r; 

  always_ff @ (posedge clk)
    if (rst) begin
      a_r <= '0;
	  posedge_out_q <= posedge_out;
	end
    else begin
      a_r <= a;
	  posedge_out_q <= posedge_out;
	end
	
 posedge_detector posedge_det(
	.clk(clk),
	.rst(rst),
	.a(a),
	.detected(posedge_out)
  );
  
assign detected = posedge_out_q & negedge_detected;
  
endmodule
