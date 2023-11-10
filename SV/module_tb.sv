`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.12.2022 14:25:27
// Design Name: 
// Module Name: module_tb
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


module module_tb
 #( parameter I_LENGTH = 16,
    parameter O_LENGTH = 32,
    parameter I_PROCESS = 2,
    parameter O_PROCESS = 4 )
  (

    );
    
    logic                             clk = 0;
    logic     [0:I_LENGTH-1][31:0]   idata;
    logic     /*[IN_LENGTH-1:0]*/         ien_data;
    logic                             ien;
    logic    [0:O_LENGTH-1][31:0]  odata;
    logic                            oen;
    logic                           full;
    logic                           fct;
    
    integer i;
    
    mod #(
        .IN_LENGTH(I_LENGTH),
        .OUT_LENGTH(O_LENGTH),
        .NB_INPUT_PROCESS(I_PROCESS),
        .NB_OUTPUT_PROCESS(O_PROCESS) ) mod
  (
        .clk        (clk        ),
        .idata      (idata      ),
        .ien_data   (ien_data   ),
        .ien        (ien        ),
        .fct        (fct        ),
        .odata      (odata      ),
        .oen        (oen        ),
        .full       (full       )
    );
    
    
    always
    begin
        clk <= !clk;
        #5;
    end
    
    initial
    begin
        for(i = 0 ; i < I_LENGTH ; i++) begin
            idata[i] = 1 << i;
        end
        
        fct = 1;
        
        #10;
        
        ien_data = 1;
        ien = 1;
        
        #15;
        
        ien_data = 0;
        ien = 0;
        
        
        for(i = 0 ; i < I_LENGTH ; i++) begin
            idata[i] = 32'h80000000 >> i;
        end
        
        #30;
        
        ien_data = 1;
        ien = 1;
        
        #15;
        
        ien_data = 0;
        ien = 0;
        
        #20;
        
        for(i = 0 ; i < I_LENGTH ; i++) begin
            idata[i] = 1 << i;
        end
        
        #2500;
        
        fct = 0;
        
        while(full) begin
            #10;
        end
        
        ien_data = 1;
        ien = 1;
        
        #15;
        
        ien_data = 0;
        ien = 0;
        
    end
    
endmodule
