`timescale 1ns / 1ps

module S_to_P_converter
# ( parameter SERIAL_LENGTH = 1,
    parameter PARALLEL_LENGTH = 32
)(
    input logic                                 clk     ,
    input logic                                 ien     ,
    input logic [0:SERIAL_LENGTH-1][31:0]       idata   ,
    input logic                                 fct     ,
    output logic                                oen     ,
    output logic [0:PARALLEL_LENGTH-1][31:0]    odata   ,
    output logic                                finished = 0
    );
    
    logic [15:0] cnt = 0;
    //logic finished = 0;
    
    integer i;
    
    
    
    
    always_ff @(posedge clk)
    begin
        if (ien & !finished) begin
            for ( i = 0 ; i < SERIAL_LENGTH ; i++) begin
                odata[i+cnt] <= idata[i];                
            end 
            //cnt <= cnt + SERIAL_LENGTH;
            if (cnt + SERIAL_LENGTH == PARALLEL_LENGTH) begin
                cnt <= 0;
                if (!fct) begin
                    oen <= 1;
                end
                else begin
                    finished <= 1;
                end
            end
            else begin
                cnt <= cnt + SERIAL_LENGTH;
            end
        end
        else if (finished & !fct) begin
            oen <= 1;
            finished <= 0;
        end
        if (oen) begin
            oen <= 0;
        end
    end
    
    
    
endmodule
