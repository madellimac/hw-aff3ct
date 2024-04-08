`timescale 1ns / 1ps

module P2S  #(parameter BUFFER_SIZE = 7)(
    input logic i_clk,
    input logic i_rst,
    input logic [BUFFER_SIZE-1:0] i_data,
    input logic i_dv,
    output logic o_data,
    output logic o_dv
    );

    logic [$clog2(BUFFER_SIZE):0] counter;
    logic [BUFFER_SIZE-1:0] buffer;
    
    always_ff @(posedge i_clk or posedge i_rst) begin
        if (i_rst) begin
            counter <= 0;
            o_dv <= 0;
            buffer <= 0;
        end else begin
            if (i_dv) begin
                counter <= BUFFER_SIZE-1; // to_unsigned(6,3)
                o_dv <= 1;
                buffer <= i_data;
            end else if (counter == 0) begin
                counter <= 0;
                o_dv <= 0;
                buffer <= buffer;
            end else begin
                counter <= counter - 1;
                o_dv <= 1;
                buffer[BUFFER_SIZE-2:0] <= buffer[BUFFER_SIZE-1:1];
                buffer[BUFFER_SIZE-1] <= 0;
            end
        end
    end
    
    assign o_data = buffer[0];
     

endmodule
