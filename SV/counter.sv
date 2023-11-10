`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2023 02:08:28 PM
// Design Name: 
// Module Name: counter
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


module counter (
    input logic i_clk,
    input logic i_rst,
    input logic i_dv,

    output logic [7:0] o_data,
    output logic o_dv);

    logic [7:0] count;

    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            count <= 8'b00000000;
            o_dv <= 1'b0;
        end
        else if(i_dv) begin
            count <= count + 1;
            o_dv <= 1'b1;
        end
     end
        
    assign o_data = count;
   // assign o_dv = i_dv;
        
endmodule
