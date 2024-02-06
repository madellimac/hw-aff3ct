`timescale 1ns / 1ps

module scrambler(
    input logic i_clk,
    input logic i_rst,
    input logic i_data,
    input logic i_dv,
    output logic o_data,
    output logic o_dv
    );
    
    logic [3:0] lfsr; 
    
    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            lfsr <= 0;
        end else if (i_dv) begin
            lfsr <= {i_data,lfsr[3:1]};        
        end
     end
    
    assign o_data = i_data;// ^ lfsr[3] ^ lfsr[1] ^ lfsr[0];
    assign o_dv = i_dv;
    
    
endmodule