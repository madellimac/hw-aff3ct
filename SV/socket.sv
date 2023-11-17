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


module socket # (parameter DATA_WITH = 8, DEPTH = 4)
                (   input logic i_clk,
                    input logic i_rst,
                    input logic [7:0] i_data,
                    input logic i_rd_en,
                    input logic i_wr_en,
                    input logic i_full,
                    output logic o_rd_en,
                    output logic [7:0 ]o_data,
                    output logic o_dv,
                    output logic o_full);

    logic empty_ctrl;

    fifo #(.DATA_WITH(DATA_WITH), .DEPTH(DEPTH)) inst_fifo( .i_clk(i_clk),
                                                                .i_rst(i_rst),
                                                                .i_data(i_data),
                                                                .i_rd_en(i_rd_en),
                                                                .i_wr_en(i_wr_en),
                                                                .o_data(o_data),
                                                                .o_dv(o_dv),
                                                                .o_full(o_full),
                                                                .o_empty(empty_ctrl));
    
    socket_controler ctrl ( .i_clk(i_clk),
                            .i_rst(i_rst), 
                            .i_full(i_full),
                            .i_empty(empty_ctrl),
                            .o_rd_en(o_rd_en)); 

endmodule               