`timescale 1ns / 1ps

module counter  #(parameter MAX_VAL = 8)(
    input logic i_clk,
    input logic i_rst,
    input logic i_init,
    input logic i_dv,

    output logic [$clog2(MAX_VAL)-1:0] o_data,
    output logic o_dv);

    logic [$clog2(MAX_VAL)-1:0] count;

    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            count <= 0;
        end else if (i_init) begin
            count <= 0;
        end else if(i_dv) begin
            if(count < MAX_VAL) 
                count <= count + 1;
            else 
                count <= 0;
        end
     end
        
   assign o_data = count;
   assign o_dv = i_dv;
        
endmodule
