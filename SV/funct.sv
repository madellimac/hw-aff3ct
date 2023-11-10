`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 25.11.2022 17:01:18
// Design Name: 
// Module Name: funct
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


module funct
#(  parameter NB_INPUT  = 1,
    parameter NB_OUTPUT = 1 
)(
    input logic                         clk         ,
    input logic                         in_en_fct   ,   
    input logic [0:NB_INPUT-1][31:0]    in_data_fct ,
    output logic                        out_en_fct  ,
    output logic [0:NB_OUTPUT-1][31:0]  out_data_fct
    );
    
    integer i;
    
    typedef enum { idle, fct, stop } state;
    state current, next;
    
    logic in_progress = 0;
    logic finished = 0;
    
    // data vectors
    logic [0:NB_INPUT-1][31:0]  data;
    logic [0:NB_OUTPUT-1][31:0] odata;
    
    
    
    
    // change state
    always @(posedge clk)
    begin
        current <= next;
    end
    
    // next state
    always_comb
    begin
        case(current)
            idle    : next = in_en_fct  ? fct   : idle  ;
            fct     : next = finished   ? stop  : fct   ;
            stop    : next =              idle          ;
            default: next = idle;
        endcase
    end
    
//    always_ff @(posedge clk)
//    begin
//        out_en_fct <= 0;
//        if(!in_progress) begin
//            if(in_en_fct) begin
//                in_progress <= 1;
//                //data <= in_data_fct;
//            end
//        end
//        else begin
//            if(finished) begin
//                out_en_fct <= 1;
//                out_data_fct <= data;
//                //finished <= 0;
//                in_progress <= 0;
//            end
//        end
//    end
    
    always_comb
    begin
        case(current)
            idle, fct   :
                begin
                    out_en_fct = 0;
                    out_data_fct = 0;
                end
            stop        :
                begin
                    out_en_fct = 1;
                    out_data_fct = odata;
                end
            default: 
                begin
                    out_en_fct = 0;
                    out_data_fct = 0;
                end
        endcase
    end
    
    always_ff @(posedge clk)
    begin
        if(current == idle) begin
            //out_en_fct <= 0;
            data <= in_data_fct;
        end
        else if(current == stop) begin
            finished <= 0;
            //out_en_fct <= 1;
            //out_data_fct <= data;
        end
        else begin
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
///////////////// change processing here /////////////////////
            if(!finished) begin
//                if ( (NB_INPUT == NB_OUTPUT) || (NB_INPUT < NB_OUTPUT) ) begin
                for( i = 0 ; i < NB_OUTPUT ; i++ ) begin
                    odata[i] <= data[0] + 1;
                end
//                end
//                else begin
                    
//                end
                finished <= 1;
            end
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////
        end
    end
    
endmodule
