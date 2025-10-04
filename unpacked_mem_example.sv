module cache_mem (
  input        clk,
  input        rst_n,
  input        rd_en,
  input        wr_en,
  input  logic [4:0] addr  ,
  input  logic [7:0] data_in  ,
  output logic [7:0] data_out
     );

  typedef struct {
    logic [4:0] addr;
    logic [7:0] data;
  } tran_t;
  
  logic [7:0] memory [0:31];
  tran_t cache [0:3];
  int j;
  

  always @(posedge clk or negedge rst_n) begin
    if (rst_n==0) begin
      for(int i=0; i<32; i++)
        memory[i] <= 8'b0;
      for (int i=0; i<4; i++) begin
        cache[i].addr <= 5'b0;
        cache[i].data <= 8'b0;
      end
    end
    else if ((wr_en==1) && (rd_en==0)) begin
      j = addr/8;
      if (cache[j].addr == addr)
       #1 cache[j].data <= data_in;
      else begin
        memory[cache[j].addr]=cache[j].data;
       #1 cache[j].addr <= addr;
        cache[j].data <= data_in;
      end
    end 
    else if ((wr_en==0) && (rd_en==1)) begin
      j = addr/8;
      //#1 data_out <= memory[addr];
      if (cache[j].addr == addr)
       	#1 data_out <= cache[j].data;
      else begin
        #1 data_out <= memory[addr];
        memory[cache[j].addr]=cache[j].data;
        cache[j].addr <= addr;
        cache[j].data <= memory[addr];
      end 
    end
  end

endmodule