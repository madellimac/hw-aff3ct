`timescale 1ns / 1ps


module S2P #(parameter BUFFER_SIZE = 4)(
    input logic i_clk,
    input logic i_rst,
    input logic i_data,
    input logic i_dv,
    output logic [BUFFER_SIZE-1:0] o_data,
    output logic o_dv
    );
    
    logic [$clog2(BUFFER_SIZE):0] bit_counter;
    logic [BUFFER_SIZE-1:0] buffer;
    
    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            bit_counter <= 0;
        end else if(i_dv) begin
            if( bit_counter == BUFFER_SIZE-1 ) 
                bit_counter <= 0;
            else 
                bit_counter <= bit_counter + 1;
        end
     end
    
    always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            buffer <= 0;
        end else if(i_dv) begin
            buffer[BUFFER_SIZE-2:0] <= buffer[BUFFER_SIZE-1:1];
            buffer[BUFFER_SIZE-1] <= i_data;
        end
     end
     
     assign o_data = buffer;
     
     always_ff @(posedge i_clk, posedge i_rst) begin
        if (i_rst) begin
            o_dv <= 0;
        end else if(i_dv && bit_counter == BUFFER_SIZE-1)
                o_dv <= 1;
            else
                o_dv <= 0;
     end     
      
endmodule
