`timescale 1ns / 1ps

module conv_encoder(
    input logic i_clk,
    input logic i_rst,
    input logic i_data,
    input logic i_dv,
    output logic [1:0] o_data,
    output logic o_dv
    );
    
    logic [1:0] buffer;
     
    assign o_data[0] = i_data ^ buffer[0]; 
    assign o_data[1] = buffer[1] ^ buffer[0];
    assign o_dv = i_dv;
    
    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            buffer <= 0;
        end else if (i_dv) begin
            buffer <= {i_data, buffer[1]};
        end
    end

endmodule
