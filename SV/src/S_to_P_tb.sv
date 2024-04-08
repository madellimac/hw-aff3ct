`timescale 1ns / 1ps

module S_to_P_tb
 #( parameter S_LENGTH = 2,
    parameter P_LENGTH = 4 )
  (

    );
    
    logic                               clk = 0;
    logic     [0:S_LENGTH-1][31:0]      idata;
    logic                               ien;
    logic     [0:P_LENGTH-1][31:0]      odata;
    logic                               oen;
    logic                               finished;
    logic                               fct;
    
    
    logic     [0:P_LENGTH-1][31:0]      data;
    
    integer i;
    
    S_to_P_converter #(
        .SERIAL_LENGTH(S_LENGTH),
        .PARALLEL_LENGTH(P_LENGTH) ) S_to_P
  (
        .clk        (clk        ),
        .ien        (ien        ),
        .idata      (idata      ),
        .fct        (fct        ),
        .oen        (oen        ),
        .odata      (odata      ),
        .finished   (finished   )
    );
    
    
    always
    begin
        clk <= !clk;
        #5;
    end
    
    initial
    begin
        for(i = 0 ; i < S_LENGTH ; i++) begin
            idata[i] = 1 << i;
        end
        
        #10;
        
        fct = 1;
        ien = 1;
        
        #10;
        
        ien = 0;
        
        for(i = 0 ; i < S_LENGTH ; i++) begin
            idata[i] = 32'h80000000 >> i;
        end
        
        #30;
        
        ien = 1;
        
        #10;
        
        ien = 0;
        
        #100;
        
        fct = 0;
        
    end
    
endmodule
