`timescale 1ns / 1ps

module processing
#(parameter SOCKET_SIZE = 4,
            PROC = "counter")
            (if_socket_to_module if_s2m, 
             if_module_to_socket if_m2s);
             
    localparam DATA_WIDTH = if_m2s.DATA_WIDTH;

    case(PROC)
        "counter" : begin
            counter #(.MAX_VAL(2**DATA_WIDTH)) source (
                .i_clk  (if_m2s.clk),
                .i_rst  (if_m2s.rst),
                .i_init (0),                                        
                .i_dv   (if_s2m.rd_en),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
        
            socket_controler #(.MAX_DATA_COUNT(SOCKET_SIZE)) ctrl ( 
                .i_clk              (if_m2s.clk),
                .i_rst              (if_m2s.rst), 
                .i_full             (if_s2m.full),
                .i_empty            (if_m2s.empty),
                .o_rd_en            (if_s2m.rd_en));
        end
        "uart_rx" : begin // TODO
        
            socket_controler #(.MAX_DATA_COUNT(SOCKET_SIZE)) ctrl ( 
                .i_clk              (if_m2s.clk),
                .i_rst              (if_m2s.rst), 
                .i_full             (if_s2m.full),
                .i_empty            (if_m2s.empty),
                .o_rd_en            (if_s2m.rd_en));
                
            assign if_m2s.data = if_s2m.data;
            assign if_m2s.dv = if_s2m.dv;
            
        end
        default : begin // passthrough
            socket_controler #(.MAX_DATA_COUNT(SOCKET_SIZE)) ctrl ( 
                .i_clk              (if_m2s.clk),
                .i_rst              (if_m2s.rst), 
                .i_full             (if_s2m.full),
                .i_empty            (if_m2s.empty),
                .o_rd_en            (if_s2m.rd_en));
                
            assign if_m2s.data = if_s2m.data;
            assign if_m2s.dv = if_s2m.dv;
        end
    endcase
    
endmodule