`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2023 03:24:54 PM
// Design Name: 
// Module Name: tb_counter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_top();

    logic        i_clk;
    logic        i_rst;
    logic        i_dv;
    
    top uut (.*);

    initial begin
        i_clk = 0;
        forever #5 i_clk = ~i_clk;
    end

    initial begin
        i_rst = 1;
        i_dv = 0;
        #10 i_rst = 0;
        #30 i_dv = 1;
        #120 i_dv = 0;
        #160 $finish;
    end

endmodule

