`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/17/2023 04:12:25 PM
// Design Name: 
// Module Name: top
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


module top( input logic i_clk,
            input logic i_rst,
            input logic i_dv);


    logic dummy1, dummy2, dummy3, dummy4, dummy5;
    logic [7:0] dummy_bus1;

counter source(   .i_clk  (i_clk),
            .i_rst  (i_rst),
            .i_dv   (i_dv),
            .o_data (data_sockA),
            .o_dv   (wr_en_sockA));

          
socket #(.DATA_WITH(8),.DEPTH(4)) socket_A( .i_clk(i_clk),
                                            .i_rst(i_rst),
                                            .i_data(data_sockA),
                                            .i_rd_en(rd_en_socketA),
                                            .i_wr_en(wr_en_sockA),
                                            .i_full(full_sockA),
                                            .o_rd_en(dummy1),
                                            .o_data(data_sockB),
                                            .o_dv(dv_sockB),
                                            .o_full(full_sockB));
                                            
socket #(.DATA_WITH(8),.DEPTH(4)) socket_B( .i_clk(i_clk),
                                            .i_rst(i_rst),
                                            .i_data(data_sockB),
                                            .i_rd_en(dummy3),
                                            .i_wr_en(dv_sockB),
                                            .i_full(full_sockB),
                                            .o_rd_en(rd_en_socketA),
                                            .o_data(dummy_bus1),
                                            .o_dv(dummy5),
                                            .o_full(dummy4));

endmodule
