`timescale 1ns / 1ps

module hamming_encoder(
input [3:0]     i_data,
input           i_dv,
output [6:0]    o_data,
output          o_dv
    );

    assign o_data[4] = i_data[0] ^ i_data[1] ^ i_data[2];
    assign o_data[5] = i_data[1] ^ i_data[2] ^ i_data[3];
    assign o_data[6] = i_data[0] ^ i_data[1] ^ i_data[3];
    
    assign o_data[3:0] = i_data[3:0];
   
    assign o_dv = i_dv;
   
endmodule
