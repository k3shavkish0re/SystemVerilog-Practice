//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module sort_two_floats_ab (
    input        [FLEN - 1:0] a,
    input        [FLEN - 1:0] b,

    output logic [FLEN - 1:0] res0,
    output logic [FLEN - 1:0] res1,
    output                    err
);

    logic a_less_or_equal_b;

    f_less_or_equal i_floe (
        .a   ( a                 ),
        .b   ( b                 ),
        .res ( a_less_or_equal_b ),
        .err ( err               )
    );

    always_comb begin : a_b_compare
        if ( a_less_or_equal_b ) begin
            res0 = a;
            res1 = b;
        end
        else
        begin
            res0 = b;
            res1 = a;
        end
    end

endmodule

//----------------------------------------------------------------------------
// Example - different style
//----------------------------------------------------------------------------

module sort_two_floats_array
(
    input        [0:1][FLEN - 1:0] unsorted,
    output logic [0:1][FLEN - 1:0] sorted,
    output                         err
);

    logic u0_less_or_equal_u1;

    f_less_or_equal i_floe
    (
        .a   ( unsorted [0]        ),
        .b   ( unsorted [1]        ),
        .res ( u0_less_or_equal_u1 ),
        .err ( err                 )
    );

    always_comb
        if (u0_less_or_equal_u1)
            sorted = unsorted;
        else
              {   sorted [0],   sorted [1] }
            = { unsorted [1], unsorted [0] };

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module sort_three_floats (
    input        [0:2][FLEN - 1:0] unsorted,
    output logic [0:2][FLEN - 1:0] sorted,
    output                         err
);

    // Task:
    // Implement a module that accepts three Floating-Point numbers and outputs them in the increasing order.
    // The module should be combinational with zero latency.
    // The solution can use up to three instances of the "f_less_or_equal" module.
    //
    // Notes:
    // res0 must be less or equal to the res1
    // res1 must be less or equal to the res1
    //
    // The FLEN parameter is defined in the "import/preprocessed/cvw/config-shared.vh" file
    // and usually equal to the bit width of the double-precision floating-point number, FP64, 64 bits.

logic ctrl1, ctrl2, ctrl3;

    f_less_or_equal floe_1 (
        .a   ( unsorted [0]      ),
        .b   ( unsorted [1]      ),
        .res ( ctrl1             ),
        .err ( err1              )
    );

    f_less_or_equal floe_2 (
        .a   ( unsorted [1]      ),
        .b   ( unsorted [2]      ),
        .res ( ctrl2             ),
        .err ( err2              )
    );
	
    f_less_or_equal floe_3 (
        .a   ( unsorted [2]      ),
        .b   ( unsorted [0]      ),
        .res ( ctrl3             ),
        .err ( err3              )
    );

assign err = err1 | err2 | err3;

always_comb begin
	case({ctrl1, ctrl2, ctrl3})
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
