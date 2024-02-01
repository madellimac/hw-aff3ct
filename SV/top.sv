`timescale 1ns / 1ps

`include "PCK/pck_module.sv"

module top( input logic i_clk,
            input logic i_rst,
            input logic i_dv);


    localparam  DATA_WIDTH = 16,
                SOCKET_SIZE = 5;
    
assign if_s2m_0.P_COUNTER.MAX_VAL = 256;

if_socket_to_module #(.DATA_WIDTH(DATA_WIDTH)) if_s2m_0 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(DATA_WIDTH)) if_s2m_1 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(DATA_WIDTH)) if_s2m_2 (i_clk, i_rst);

if_module_to_socket #(.DATA_WIDTH(DATA_WIDTH)) if_m2s_0 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(DATA_WIDTH)) if_m2s_1 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(DATA_WIDTH)) if_m2s_2 (i_clk, i_rst);

assign if_s2m_0.data = 0;
assign if_s2m_0.full = 1; 
 
mod #(.SOCKET_SIZE(SOCKET_SIZE), .PROC("counter")) source_counter(if_s2m_0, if_m2s_0);

socket #(.DEPTH(SOCKET_SIZE)) socket_A(if_m2s_0, if_s2m_1);

mod #(.SOCKET_SIZE(SOCKET_SIZE), .PROC("void")) passthrough (if_s2m_1, if_m2s_1);
                                                                        
socket #(.DEPTH(SOCKET_SIZE)) socket_B(if_m2s_1, if_s2m_2);

mod #(.SOCKET_SIZE(SOCKET_SIZE), .PROC("void")) sink(if_s2m_2, if_m2s_2);
assign if_m2s_2.empty = 1;

        
endmodule
