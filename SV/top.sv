`timescale 1ns / 1ps

module top( input logic i_clk,
            input logic i_rst,
            input logic i_dv);


    localparam  DATA_WIDTH = 16,
                SOCKET_SIZE = 5;
                
    // source counter
    logic   source_counter_rd_en,            
            source_counter_dv;
    logic [DATA_WIDTH-1:0] source_counter_data;
    
    // socket A
    logic   socket_A_dv,
            socket_A_full,
            socket_A_empty;
            
    logic [DATA_WIDTH-1:0] socket_A_data;
    
    // socket B
    logic   socket_B_rd_en,
            socket_B_dv,
            socket_B_full,
            socket_B_empty;
            
    logic [DATA_WIDTH-1:0] socket_B_data;
    
    // passthrough
    logic   passthrough_rd_en,
            passthrough_dv;
    
    logic [DATA_WIDTH-1:0] passthrough_data;
    
    // sink
    logic   sink_rd_en,
            sink_dv;
    
    logic [DATA_WIDTH-1:0] sink_data;
    

mod #(.DATA_WIDTH(DATA_WIDTH), .SOCKET_SIZE(SOCKET_SIZE), .TASK("counter")) source_counter(
    .i_clk   (i_clk),
    .i_rst   (i_rst),
    .i_data  (0),
    .i_dv    (source_counter_rd_en),
    .i_empty (socket_A_empty),
    .i_full  (1),  
      
    .o_rd_en (source_counter_rd_en),
    .o_data  (source_counter_data),
    .o_dv    (source_counter_dv));
                                              
socket #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(SOCKET_SIZE)) socket_A(
    .i_clk    (i_clk),
    .i_rst    (i_rst),
    .i_data   (source_counter_data),
    .i_rd_en  (passthrough_rd_en),
    .i_wr_en  (source_counter_dv), // rename i_dv
    
    .o_data   (socket_A_data),
    .o_dv     (socket_A_dv),
    .o_full   (socket_A_full),
    .o_empty  (socket_A_empty));

mod #(.DATA_WIDTH(DATA_WIDTH), .SOCKET_SIZE(SOCKET_SIZE), .TASK("void")) passthrough(
    .i_clk   (i_clk),
    .i_rst   (i_rst),
    .i_data  (socket_A_data),
    .i_dv    (socket_A_dv),
    .i_empty (socket_B_empty),
    .i_full  (socket_A_full),
    
    .o_rd_en (passthrough_rd_en),
    .o_data  (passthrough_data),
    .o_dv    (passthrough_dv));
    
                                                                        
socket #(.DATA_WIDTH(DATA_WIDTH),.DEPTH(SOCKET_SIZE)) socket_B(
    .i_clk    (i_clk),
    .i_rst    (i_rst),
    .i_data   (passthrough_data),
    .i_rd_en  (sink_rd_en),
    .i_wr_en  (passthrough_dv),
    
    .o_data   (socket_B_data),
    .o_dv     (socket_B_dv),
    .o_full   (socket_B_full),
    .o_empty  (socket_B_empty));

mod #(.DATA_WIDTH(DATA_WIDTH), .SOCKET_SIZE(SOCKET_SIZE), .TASK("void")) sink(
    .i_clk   (i_clk),
    .i_rst   (i_rst),
    .i_data  (socket_B_data),
    .i_dv    (socket_B_dv),
    .i_empty (1),
    .i_full  (socket_B_full),
    
    .o_rd_en (sink_rd_en),
    .o_data  (sink_data),
    .o_dv    (sink_dv));
        
endmodule
