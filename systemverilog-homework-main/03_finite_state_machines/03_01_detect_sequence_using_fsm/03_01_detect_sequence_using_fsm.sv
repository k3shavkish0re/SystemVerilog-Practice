//----------------------------------------------------------------------------
// Example
//----------------------------------------------------------------------------

module detect_4_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Detection of the "1010" sequence

  // States (F — First, S — Second)
  enum logic[2:0]
  {
     IDLE = 3'b000,
     F1   = 3'b001,
     F0   = 3'b010,
     S1   = 3'b011,
     S0   = 3'b100
  }
  state, new_state;

  // State transition logic
  always_comb
  begin
    new_state = state;

    // This lint warning is bogus because we assign the default value above
    // verilator lint_off CASEINCOMPLETE

    case (state)
      IDLE: if (  a) new_state = F1;
      F1:   if (~ a) new_state = F0;
      F0:   if (  a) new_state = S1;
            else     new_state = IDLE;
      S1:   if (~ a) new_state = S0;
            else     new_state = F1;
      S0:   if (  a) new_state = S1;
            else     new_state = IDLE;
    endcase

    // verilator lint_on CASEINCOMPLETE

  end

  // Output logic (depends only on the current state)
  assign detected = (state == S0);

  // State update
  always_ff @ (posedge clk)
    if (rst)
      state <= IDLE;
    else
      state <= new_state;

endmodule

//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module detect_6_bit_sequence_using_fsm
(
  input  clk,
  input  rst,
  input  a,
  output detected
);

  // Task:
  // Implement a module that detects the "110011" input sequence
  //
  // Hint: See Lecture 3 for details
  enum logic[2:0]
  {
     IDLE = 3'b000,
     S0   = 3'b001,
     S1   = 3'b010,
     S2   = 3'b011,
     S3   = 3'b100,
	 S4   = 3'b101,
	 S5   = 3'b110
  }
  state_d, state_q;


  always_comb
  begin
    state_d = state_q;

    case (state_q)
      IDLE: if (  a) state_d = S0;
      S0:   if (~ a) state_d = IDLE;
			else 	 state_d = S1;
      S1:   if (  a) state_d = S1;
            else     state_d = S2;
      S2:   if (~ a) state_d = S3;
            else     state_d = S1;
      S3:   if (  a) state_d = S4;
            else     state_d = IDLE;
      S4:   if (  a) state_d = S5;
            else     state_d = IDLE;
      S5:   if (  a) state_d = S1;
            else     state_d = S2;
    endcase
  end
  
    // State update
  always_ff @ (posedge clk)
    if (rst)
      state_q <= IDLE;
    else
      state_q <= state_d;

  // Output logic (depends only on the current state)
  assign detected = (state_q == S5);


endmodule
