//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    // Implement a module that calculates the formula from the `formula_2_fn.svh` file
    // using only one instance of the isqrt module.
    //
    // Design the FSM to calculate answer step-by-step and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm


logic [31:0] res_d;
logic [31:0] res_q;
logic res_vld_d;
logic res_vld_q;

enum logic [1:0] {
	IDLE = 2'd0,
	state_1 = 2'd1,
	state_2 = 2'd2,
	state_3 = 2'd3
} state_d, state_q;

assign isqrt_x = (state_q == state_1) ? c : (state_q == state_2) ? b + isqrt_y : (state_q == state_3) ? a + isqrt_y: '0;
assign isqrt_x_vld_d = ((state_q == IDLE) & (state_d == state_1)) | ((state_q == state_1) & (state_d == state_2)) | ((state_q == state_2) & (state_d == state_3)) ? 1'b1 : '0;

assign res_d = (state_q == IDLE) ? '0 : (isqrt_y_vld) ? isqrt_y : res_q;

assign res_vld = res_vld_q;
assign res = res_q;

always_comb begin
	state_d = state_q;
	case(state_q)
		IDLE: if(arg_vld) state_d = state_1;
			  else state_d = IDLE;
		state_1: if(isqrt_y_vld) state_d = state_2;
				 else state_d = state_1;
		state_2: if(isqrt_y_vld) state_d = state_3;
				 else state_d = state_2;
		state_3: if(isqrt_y_vld) state_d = IDLE;
				 else state_d = state_3;
	endcase
end

always_ff @ (posedge clk)
    if (rst) begin
        state_q <= '0;
		res_q   <= '0;
		res_vld_q <= '0;
		isqrt_x_vld <= '0;
	end
    else begin
        state_q <= state_d;
		res_q <= res_d;
		isqrt_x_vld <= isqrt_x_vld_d;
		if((state_q == state_3) && isqrt_y_vld) begin
			res_vld_q <= 1'b1;
		end
		else res_vld_q <= 1'b0;
	end

endmodule
