//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module round_robin_arbiter_with_2_requests
(
    input        clk,
    input        rst,
    input  [1:0] requests,
    output [1:0] grants
);
    // Task:
    // Implement a "arbiter" module that accepts up to two requests
    // and grants one of them to operate in a round-robin manner.
    //
    // The module should maintain an internal register
    // to keep track of which requester is next in line for a grant.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.
    //
    // Example:
    // requests -> 01 00 10 11 11 00 11 00 11 11
    // grants   -> 01 00 10 01 10 00 01 00 10 01


logic last_grant_d;
logic last_grant_q;



assign last_grant_d = requests[1] & requests[0] ? !last_grant_q :
					  requests[1] & ~requests[0] ? 1'b1 :
				      ~requests[1] & requests[0] ? 1'b0 :
				      last_grant_q;

  always_ff @ (posedge clk)
    if (rst)
    begin
	  last_grant_q <= '0;
    end
    else
    begin
	  last_grant_q <= last_grant_d;
    end


assign grants = requests[1] & requests[0] ? ((last_grant_q == '0) ? 2'b10 : 2'b01) :
				requests[1] & ~requests[0] ? 2'b10 :
				~requests[1] & requests[0] ? 2'b01 :
				'0;

endmodule
