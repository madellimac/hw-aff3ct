`timescale 1ns / 1ps

`include "../SV/src/if_socket_to_module"
`include "../SV/src/if_module_to_socket"

module top( input        logic clock,
            input        logic reset,
            input        logic io_i_dv,
            input [7:0]  logic io_i_data,
            output       logic io_o_dv,
            output [7:0] logic io_o_data);

    localparam  DATA_WIDTH = 1,
                SOCKET_SIZE = 4;
    
assign if_s2m_0.P_COUNTER.MAX_VAL = 256;

if_socket_to_module #(.DATA_WIDTH(1))  if_s2m_0 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(1))  if_s2m_1 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(1))  if_s2m_2 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(4))  if_s2m_3 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(7))  if_s2m_4 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(1))  if_s2m_5 (i_clk, i_rst);
if_socket_to_module #(.DATA_WIDTH(1))  if_s2m_6 (i_clk, i_rst);


if_module_to_socket #(.DATA_WIDTH(1))  if_m2s_0 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(1))  if_m2s_1 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(4))  if_m2s_2 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(7))  if_m2s_3 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(1))  if_m2s_4 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(1))  if_m2s_5 (i_clk, i_rst);
if_module_to_socket #(.DATA_WIDTH(2))  if_m2s_6 (i_clk, i_rst);

assign if_s2m_0.data = 0;
assign if_s2m_0.full = 1;
 
mod #(.SOCKET_SIZE(4), .PROC("file_reader"))
file_reader(if_s2m_0, if_m2s_0);

socket #(.DEPTH(4))
socket_A(if_m2s_0, if_s2m_1);

mod #(.SOCKET_SIZE(4), .PROC("scrambler"))
scr (if_s2m_1, if_m2s_1);
                                                                        
socket #(.DEPTH(4))
socket_B(if_m2s_1, if_s2m_2);

// mod #(.SOCKET_SIZE(4), .PROC("S2P"))
// S2P(if_s2m_2, if_m2s_2);

// socket #(.DEPTH(1))
// socket_C(if_m2s_2, if_s2m_3);

// mod #(.SOCKET_SIZE(1), .PROC("hamming_encoder"))
// ham_enc(if_s2m_3, if_m2s_3);

// socket #(.DEPTH(1))
// socket_D(if_m2s_3, if_s2m_4);

// mod #(.SOCKET_SIZE(1), .PROC("P2S"))
// P2S(if_s2m_4, if_m2s_4);

// socket #(.DEPTH(7))
// socket_E(if_m2s_4, if_s2m_5);

// mod #(.SOCKET_SIZE(7), .PROC("interleaver"))
// interleaver(if_s2m_5, if_m2s_5);

// socket #(.DEPTH(7))
// socket_F(if_m2s_5, if_s2m_6);

// mod #(.SOCKET_SIZE(7), .PROC("conv_encoder"))
// conv_encoder(if_s2m_6, if_m2s_6);

// assign if_m2s_6.empty = 1;
        
endmodule
