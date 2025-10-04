//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
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
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

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

enum logic [1:0] {
	o_idle = 2'd0,
	o_state_1 = 2'd1,
	o_state_2 = 2'd2,
	o_state_3 = 2'd3
} o_state_d, o_state_q;

assign isqrt_x = (state_q == state_1) ? a : (state_q == state_2) ? b : (state_q == state_3) ? c : '0;
assign isqrt_x_vld_d = ((state_q == IDLE) & (state_d == state_1)) | ((state_q == state_1) & (state_d == state_2)) | ((state_q == state_2) & (state_d == state_3)) ? 1'b1 : '0;



assign res_d = (state_q == o_idle) ? '0 : (isqrt_y_vld) ? isqrt_y : res_q;
assign res_vld = res_vld_q;
assign res = res_q;

always_comb begin
	state_d = state_q;
	case(state_q)
		IDLE: if(arg_vld) state_d = state_1;
			  else state_d = IDLE;
		state_1: state_d = state_2;
		state_2: state_d = state_2;
		state_3: state_d = IDLE;
	endcase
end

always_comb begin
	o_state_d = o_state_q;
	case(o_state_q)
		o_idle: if(arg_vld) state_d = state_1;
			  else state_d = IDLE;
		o_state_1: state_d = state_2;
		o_state_2: state_d = state_2;
		o_state_3: state_d = IDLE;
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
