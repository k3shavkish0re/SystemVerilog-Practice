//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
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

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm
	
logic [31:0] res_d;
logic [31:0] res_q;
logic res_vld_d;
logic res_vld_q;
	
assign isqrt_1_x = (state_q == first_stage) ? a : (state_q == second_stage) ? c : '0;
assign isqrt_2_x = (state_q == first_stage) ? b : (state_q == second_stage) ? 32'b0 : '0;

assign isqrt_1_x_vld_d = ((state_q == IDLE) & (state_d == first_stage)) | ((state_q == first_stage) & (state_d == second_stage)) ? 1'b1 : 1'b0;
assign isqrt_2_x_vld_d = ((state_q == IDLE) & (state_d == first_stage)) | ((state_q == first_stage) & (state_d == second_stage)) ? 1'b1 : 1'b0;


assign res_d = (state_q == IDLE) ? '0 : (isqrt_1_y_vld & isqrt_2_y_vld) ? res_q + isqrt_1_y + isqrt_2_y : res_q;

assign res_vld = res_vld_q;
assign res = res_q;
	
enum logic [1:0] {
	IDLE = 2'd0,
	first_stage = 2'd1,
	second_stage = 2'd2
} state_d, state_q;

always_comb begin
	state_d = state_q;
	case(state_q)
		IDLE: if(arg_vld) state_d = first_stage;
			  else state_d = IDLE;
		first_stage: if(isqrt_1_y_vld && isqrt_2_y_vld) state_d = second_stage;
					 else state_d = first_stage;
		second_stage: if(isqrt_1_y_vld && isqrt_2_y_vld) state_d = IDLE;
					  else state_d = second_stage;
	endcase
end


always_ff @ (posedge clk)
    if (rst) begin
        state_q <= '0;
		res_q   <= '0;
		res_vld_q <= '0;
		isqrt_1_x_vld <= '0;
		isqrt_2_x_vld <= '0;
	end
    else begin
        state_q <= state_d;
		isqrt_1_x_vld <= isqrt_1_x_vld_d;
		isqrt_2_x_vld <= isqrt_2_x_vld_d;
		res_q <= res_d;
		if((state_q == second_stage) && isqrt_1_y_vld && isqrt_2_y_vld) begin
			res_vld_q <= 1'b1;
		end
		else res_vld_q <= 1'b0;
	end
endmodule
