//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module serial_to_parallel
# (
    parameter width = 8
)
(
    input                      clk,
    input                      rst,

    input                      serial_valid,
    input                      serial_data,

    output logic               parallel_valid,
    output logic [width - 1:0] parallel_data
);
    // Task:
    // Implement a module that converts serial data to the parallel multibit value.
    //
    // The module should accept one-bit values with valid interface in a serial manner.
    // After accumulating 'width' bits, the module should assert the parallel_valid
    // output and set the data.
    //
    // Note:
    // Check the waveform diagram in the README for better understanding.

logic [2:0] count_d;
logic [2:0] count_q;

logic [width - 1 : 0] data;
 
assign count_d = count_q + 1;

  always_ff @ (posedge clk)
    if (rst)
    begin
      count_q <= '0;
	  data <= '0;
    end
    else
    begin
	  if(serial_valid) begin
		count_q <= count_d;
		data[count_q] <= serial_data;
	  end
    end


assign parallel_valid = (count_q == 3'b111) & serial_valid;
assign parallel_data = (count_q == 3'b111) & serial_valid ? {serial_data , data[6:0]} : '0;

endmodule
