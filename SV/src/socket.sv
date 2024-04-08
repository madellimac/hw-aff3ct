`timescale 1ns / 1ps

module socket # ( parameter DEPTH = 4)
                ( if_module_to_socket if_m2s,
                  if_socket_to_module if_s2m);  

fifo #(.DEPTH(DEPTH)) inst_fifo(if_m2s, if_s2m);

endmodule
