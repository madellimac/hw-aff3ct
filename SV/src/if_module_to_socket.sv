interface if_module_to_socket #(parameter DATA_WIDTH = 8) (input logic clk, rst);

   logic empty;   
   logic [DATA_WIDTH-1:0] data;
   logic dv;
   
   //modport mod_module(input empty, output data, dv);
   //modport mod_socket(input data, dv, output empty);
   
endinterface
