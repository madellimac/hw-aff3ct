module file_reader #(DATA_WIDTH = 8, DATA_COUNT = 256, FILE_NAME="data.txt")
( input logic i_clk,    
  input logic i_rst,
  input logic i_enable,     
  output logic [DATA_WIDTH-1:0] o_data,
  output logic o_data_valid
);

  logic [DATA_WIDTH-1:0] byte_data;
  logic [DATA_WIDTH-1:0] file_data [0:DATA_COUNT-1];

  int file_index;

  initial begin
    $readmemh(FILE_NAME, file_data);
  end

  always_ff @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
      byte_data <= 0;
      o_data_valid <= 0;
      file_index <= 0;
    end else begin
        if (i_enable) begin 
            byte_data <= file_data[file_index];
            o_data_valid <= 1;
            file_index <= file_index + 1;
         end else begin
            byte_data <= file_data[file_index];
            o_data_valid <= 0;
            file_index <= file_index;
         end
    end
  end

  assign o_data = byte_data;

endmodule
