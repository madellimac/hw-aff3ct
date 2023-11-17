`timescale 1ns / 1ps 
////////////////////////////////////////////////////////////////////////////////// 
// Company:  
// Engineer:  
//  
// Create Date: 11/10/2023 08:31:42 AM 
// Design Name:  
// Module Name: socket_controler 
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
 
 
module socket_controler( 
    input logic  i_clk, 
    input logic  i_rst, 
    input logic  i_full, 
    input logic  i_empty, 
     
    output logic o_rd_en);
 
    typedef enum { st_wait , st_pull } t_state; 
 
    t_state current_state, next_state; 
 
    always_ff @ ( posedge i_clk , posedge i_rst ) 
        if ( i_rst ) 
            current_state <= st_wait; 
        else 
            current_state <= next_state ; 
                 
    always_comb begin 
        next_state = current_state ; // default state : the same 
        o_rd_en = 1'b0; 
        unique case ( current_state ) 
            st_wait : begin        
                o_rd_en = 0'b0;
                if ( i_empty == 1'b0 | i_full == 1'b0 ) 
                    next_state = st_wait; 
                else 
                    next_state = st_pull; 
            end 
            st_pull : begin 
                o_rd_en = 1'b1 ; 
                if ( i_empty == &'b1 & i_full == 1'b1 ) 
                    next_state = st_pull;
                else
                    next_state = st_wait;
            end
        endcase
    end
endmodule