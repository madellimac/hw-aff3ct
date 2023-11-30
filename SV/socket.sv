`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2023 04:44:14 PM
// Design Name: 
// Module Name: socket
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


module socket # (parameter DATA_WIDTH = 8, DEPTH = 4)
                (   input logic i_clk,
                    input logic i_rst,
                    input logic [DATA_WIDTH-1:0] i_data,
                    input logic i_rd_en,
                    input logic i_wr_en,
                    
                    output logic [DATA_WIDTH-1:0 ]o_data,
                    output logic o_dv,
                    output logic o_full,
                    output logic o_empty);


    fifo #(.DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH)) inst_fifo(
        .i_clk(i_clk),
        .i_rst(i_rst),
        .i_data(i_data),
        .i_rd_en(i_rd_en),
        .i_wr_en(i_wr_en),
        
        .o_data(o_data),
        .o_dv(o_dv),
        .o_full(o_full),
        .o_empty(o_empty));


endmodule               