`timescale 1ns / 1ps

`include "PCK/pck_module.sv"

module mod #(parameter SOCKET_SIZE = 4, PROC = "counter")
            ( if_socket_to_module if_s2m, 
              if_module_to_socket if_m2s );
    
    processing #(.PROC(PROC), .SOCKET_SIZE(SOCKET_SIZE)) process_block (if_s2m, if_m2s);

                             
endmodule
