`timescale 1ns / 1ps

module mod #(parameter DATA_WIDTH = 8, SOCKET_SIZE = 4, TASK = "counter")(
    input logic i_clk,
    input logic i_rst,
    input logic [DATA_WIDTH-1:0] i_data,
    input logic i_dv,
    input logic i_empty,
    input logic i_full,
    
    output logic o_rd_en,
    output logic [DATA_WIDTH-1:0] o_data,
    output logic o_dv);
    
    if(TASK == "counter") begin
        counter #(.MAX_VAL(2**DATA_WIDTH)) source (
            .i_clk  (i_clk),
            .i_rst  (i_rst),
            .i_init (0),                                        
            .i_dv   (i_dv),
            .o_data (o_data),
            .o_dv   (o_dv));
    
        socket_controler #(.MAX_DATA_COUNT(SOCKET_SIZE)) ctrl ( 
            .i_clk              (i_clk),
            .i_rst              (i_rst), 
            .i_full             (i_full),
            .i_empty            (i_empty),
            .o_rd_en            (o_rd_en)); 
            
    end else begin
        
        socket_controler #(.MAX_DATA_COUNT(SOCKET_SIZE)) ctrl ( 
            .i_clk              (i_clk),
            .i_rst              (i_rst), 
            .i_full             (i_full),
            .i_empty            (i_empty),
            .o_rd_en            (o_rd_en));
            
        assign o_data = i_data;
        assign o_dv = i_dv;
        
    end
                             
endmodule
