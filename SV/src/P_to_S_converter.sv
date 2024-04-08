`timescale 1ns / 1ps

module P_to_S_converter
# ( parameter PARALLEL_LENGTH = 32,
    parameter SERIAL_LENGTH = 1
)(
    input logic                                 clk     ,
    input logic                                 ien     ,
    input logic [0:PARALLEL_LENGTH-1][31:0]     idata   ,
    input logic                                 fct     ,
    output logic                                oen     ,
    output logic [0:SERIAL_LENGTH-1][31:0]      odata   ,
    output logic                                full    = 0
//    output logic                                finished = 0
    );
    
    
    
    
    logic [15:0] cnt = 0;
    logic [0:PARALLEL_LENGTH-1][31:0] data;
    logic in_progress = 0;
    //logic finished = 0;
    
    integer i;
    
    
    always_ff @(posedge clk) begin
        oen <= 0;
        if (in_progress) begin
            for ( i = 0 ; i < SERIAL_LENGTH ; i++) begin
                odata[i] <= data[i+cnt];                
            end
            if (!fct) begin
                oen <= 1;
                if (cnt + SERIAL_LENGTH == PARALLEL_LENGTH) begin
                    cnt <= 0;
                    full <= 0;
                    in_progress <= 0;
                end
                else begin
                    cnt <= cnt + SERIAL_LENGTH;
                end
            end
            else begin
                oen <= 0;
            end
        end
        else if (ien & !full) begin
            in_progress <= 1;
            data <= idata;
            full <= 1;
        end
    end
    
    
endmodule
