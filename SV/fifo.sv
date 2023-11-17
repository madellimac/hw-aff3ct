`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/09/2023 11:51:42 AM
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


module fifo #(parameter DATA_WIDTH = 8, DEPTH = 4)(
    input logic i_clk,
    input logic i_rst,
    input logic [7:0] i_data,
    input logic i_rd_en,
    input logic i_wr_en,
    input logic i_full,
    
    output logic o_rd_en,
    output logic [7:0] o_data,
    output logic o_dv,
    output logic o_full,
    output logic o_empty);

    // Déclaration du tableau de stockage des données
    logic [DATA_WIDTH-1:0] fifo [DEPTH-1:0];

    // Déclaration des pointeurs de lecture et écriture
    logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;

    // Logique de contrôle
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            wr_ptr <= 0;
            fifo[DEPTH-1:0] <= '{4{8'b0}};
            //fifo[DEPTH-1:0] <= {8'b0};
        end else begin
            if (i_wr_en && !o_full) begin
                fifo[wr_ptr] <= i_data;
                wr_ptr <= wr_ptr + 1;
            end           
        end
    end

    // Logique de contrôle
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            rd_ptr <= 0;
            o_dv <= 1'b1;
        end else begin
            if (i_rd_en && !o_empty) begin
                o_data <= fifo[rd_ptr];
                o_dv <= 1'b1;
                rd_ptr <= rd_ptr + 1;
            end
        end
    end
    // Logique de statut
    assign o_full = (wr_ptr == rd_ptr + DEPTH);
    assign o_empty = (wr_ptr == rd_ptr);



endmodule

