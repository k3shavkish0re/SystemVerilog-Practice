//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module float_discriminant (
    input                     clk,
    input                     rst,

    input                     arg_vld,
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,
    input        [FLEN - 1:0] c,

    output logic              res_vld,
    output logic [FLEN - 1:0] res,
    output logic              res_negative,
    output logic              err,

    output logic              busy
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs their discriminant.
    // The resulting value res should be calculated as a discriminant of the quadratic polynomial.
    // That is, res = b^2 - 4ac == b*b - 4*a*c
    //
    // Note:
    // If any argument is not a valid number, that is NaN or Inf, the "err" flag should be set.
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

logic 					i_mult_1_err;
logic [5:0]				i_mult_1_err_q;
logic 					i_mult_1_rdy;
logic [2:0]				i_mult_1_rdy_q;
logic [FLEN-1:0] 		i_mult_1_res;
logic [2:0][FLEN-1:0] 	i_mult_1_res_q;

logic 					i_mult_2_err;
logic [5:0]				i_mult_2_err_q;
logic 					i_mult_2_rdy;
logic [FLEN-1:0] 		i_mult_2_res;

logic 					i_mult_3_err;
logic [2:0]				i_mult_3_err_q;
logic 					i_mult_3_rdy;
logic [FLEN-1:0] 		i_mult_3_res;

logic 					i_sub_1_err;
logic 					i_sub_1_rdy;
logic [FLEN-1:0] 		i_sub_1_res;



f_mult i_mult_1(
    .clk        (clk),
    .rst        (rst),
    .a          (b),
    .b          (b),
    .up_valid   (arg_vld),
    .res        (i_mult_1_res),
    .down_valid (i_mult_1_rdy),
    .busy       (),
    .error      (i_mult_1_err)
);

//add 3 stage shift register for i_mult_1_res/rdy/err
integer i;

always_ff @(posedge clk) begin
    if (rst) begin
        i_mult_1_err_q <= '0;
        i_mult_1_rdy_q <= '0;
        i_mult_1_res_q <= '0;
    end 
	else begin
        i_mult_1_err_q[0] <= i_mult_1_err;
        i_mult_1_rdy_q[0] <= i_mult_1_rdy;
        i_mult_1_res_q[0] <= i_mult_1_res;

        for (i = 1; i < 3; i++) begin
            i_mult_1_rdy_q[i] <= i_mult_1_rdy_q[i-1];
            i_mult_1_res_q[i] <= i_mult_1_res_q[i-1];
        end
		for (i = 1; i < 6; i++) begin
            i_mult_1_err_q[i] <= i_mult_1_err_q[i-1];
        end
    end
end


f_mult i_mult_2(
    .clk        (clk),
    .rst        (rst),
    .a          (a),
    .b          (c),
    .up_valid   (arg_vld),
    .res        (i_mult_2_res),
    .down_valid (i_mult_2_rdy),
    .busy       (),
    .error      (i_mult_2_err)
);

always_ff @(posedge clk) begin
    if (rst) begin
        i_mult_2_err_q <= '0;
    end 
	else begin
        i_mult_2_err_q[0] <= i_mult_2_err;
        for (i = 1; i < 6; i++) begin
            i_mult_2_err_q[i] <= i_mult_2_err_q[i-1];
        end
    end
end

logic [FLEN - 1: 0] four = 64'h4010000000000000;

f_mult i_mult_3(
    .clk        (clk),
    .rst        (rst),
    .a          (four),
    .b          (i_mult_2_res),
    .up_valid   (i_mult_2_rdy),
    .res        (i_mult_3_res),
    .down_valid (i_mult_3_rdy),
    .busy       (),
    .error      (i_mult_3_err)
);

always_ff @(posedge clk) begin
    if (rst) begin
        i_mult_3_err_q <= '0;
    end 
	else begin
        i_mult_3_err_q[0] <= i_mult_3_err;
        for (i = 1; i < 4; i++) begin
            i_mult_3_err_q[i] <= i_mult_3_err_q[i-1];
        end
    end
end

f_sub i_sub_1(
    .clk        (clk),
    .rst        (rst),
    .a          (i_mult_1_res_q[2]),
    .b          (i_mult_3_res),
    .up_valid   (i_mult_1_rdy_q[2] && i_mult_3_rdy),
    .res        (i_sub_1_res),
    .down_valid (i_sub_1_rdy),
    .busy       (busy),
    .error      (i_sub_1_err)
);

assign err = i_sub_1_err | i_mult_1_err_q[5] | i_mult_2_err_q[5] | i_mult_3_err_q[2];
assign res_vld = i_sub_1_rdy;
assign res = i_sub_1_res;
assign res_negative = i_sub_1_res[63];

endmodule
