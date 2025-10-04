//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_floats_using_fsm (
    input                          clk,
    input                          rst,

    input                          valid_in,
    input        [0:2][FLEN - 1:0] unsorted,

    output logic                   valid_out,
    output logic [0:2][FLEN - 1:0] sorted,
    output logic                   err,
    output                         busy,

    // f_less_or_equal interface
    output logic      [FLEN - 1:0] f_le_a,
    output logic      [FLEN - 1:0] f_le_b,
    input                          f_le_res,
    input                          f_le_err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order using FSM.
    //
    // Requirements:
    // The solution must have latency equal to the three clock cycles.
    // The solution should use the inputs and outputs to the single "f_less_or_equal" module.
    // The solution should NOT create instances of any modules.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

enum logic [1:0] {
	state_1 = 2'd0,
	state_2 = 2'd1,
	state_3 = 2'd2
} state_d, state_q;

logic ctrl1_d, ctrl1_q, ctrl2_d, ctrl2_q, ctrl3_d, ctrl3_q;
logic valid_out_q;
logic err_d;

assign ctrl1_d = (state_q == state_1) & (state_d == state_2) ? f_le_res : ctrl1_q;
assign ctrl2_d = (state_q == state_2) & (state_d == state_3) ? f_le_res : ctrl2_q;
assign ctrl3_d = (state_q == state_3) & (state_d == state_1) ? f_le_res : ctrl3_q;

assign f_le_a = (state_q == state_1) ? unsorted[0] : (state_q == state_2) ? unsorted[1] : unsorted[2] ;
assign f_le_b = (state_q == state_1) ? unsorted[1] : (state_q == state_2) ? unsorted[2] : unsorted[0] ;

assign valid_out = valid_out_q;
assign err_d = f_le_err | (err & !valid_in);
always_comb begin
	state_d = state_q;
	case(state_q)
		state_1: if(valid_in) state_d = state_2;
			     else state_d = state_1;
		state_2: //if(f_le_err) state_d = state_1;
				 state_d = state_3;
		state_3: state_d = state_1;
	endcase
end

always_ff @ (posedge clk)
    if (rst) begin
        state_q <= '0;
		ctrl1_q <= '0;
		ctrl2_q <= '0;
		ctrl3_q <= '0;
		valid_out_q <= '0;
		err <= '0;
	end
    else begin
        state_q <= state_d;
		ctrl1_q <= ctrl1_d;
		ctrl2_q <= ctrl2_d;
		ctrl3_q <= ctrl3_d;
		valid_out_q <= (state_q == state_3) & (state_d == state_1);
		err <= err_d;
	end

always_comb begin
	case({ctrl1_q, ctrl2_q, ctrl3_q})
		3'd0: sorted = unsorted;
		3'd1: sorted = {unsorted[2], unsorted[1] , unsorted[0]};
		3'd2: sorted = {unsorted[1], unsorted[0] , unsorted[2]};
		3'd3: sorted = {unsorted[1], unsorted[2] , unsorted[0]};
		3'd4: sorted = {unsorted[0], unsorted[2] , unsorted[1]};
		3'd5: sorted = {unsorted[2], unsorted[0] , unsorted[1]};
		3'd6: sorted = {unsorted[0], unsorted[1] , unsorted[2]};
		3'd7: sorted = unsorted;
		default sorted = unsorted;
	endcase
end

endmodule
