`timescale 1ns / 1ps

module processing
#(parameter SOCKET_SIZE = 4,
            PROC = "counter")
            (if_socket_to_module if_s2m, 
             if_module_to_socket if_m2s);
             
             
    localparam DATA_WIDTH = if_m2s.DATA_WIDTH;

    socket_controler #(.MAX_DATA_COUNT(SOCKET_SIZE)) ctrl ( 
                .i_clk              (if_m2s.clk),
                .i_rst              (if_m2s.rst), 
                .i_full             (if_s2m.full),
                .i_empty            (if_m2s.empty),
                .o_rd_en            (if_s2m.rd_en)); 
                
    case(PROC)
        "counter" : begin
            counter #(.MAX_VAL(2**DATA_WIDTH)) source (
                .i_clk  (if_m2s.clk),
                .i_rst  (if_m2s.rst),
                .i_init (0),                                        
                .i_dv   (if_s2m.rd_en),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
        
        end
        "file_reader" : begin
        
            file_reader #(.DATA_WIDTH(DATA_WIDTH)) file_read
            (
                .i_clk          (if_m2s.clk),
                .i_rst          (if_m2s.rst),
                .i_enable       (if_s2m.rd_en),
                .o_data         (if_m2s.data),
                .o_data_valid   (if_m2s.dv));
            
        end
        "scrambler" : begin
        
            scrambler scr
            (
                .i_clk  (if_m2s.clk),
                .i_rst  (if_m2s.rst),
                .i_data (if_s2m.data),
                .i_dv   (if_s2m.dv),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
        
        end
        "S2P" : begin
        
            S2P #(.BUFFER_SIZE(SOCKET_SIZE)) inst_s2p
            (
                .i_clk  (if_m2s.clk),
                .i_rst  (if_m2s.rst),
                .i_data (if_s2m.data),
                .i_dv   (if_s2m.dv),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
            
        end
        "hamming_encoder" : begin
        
            hamming_encoder ham_enc
            (
                .i_data (if_s2m.data),
                .i_dv   (if_s2m.dv),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
            
        end
        "P2S" : begin
        
            P2S inst_p2s
            (
                .i_clk  (if_m2s.clk),
                .i_rst  (if_m2s.rst),
                .i_data (if_s2m.data),
                .i_dv   (if_s2m.dv),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
            
        end
        "interleaver" : begin
        
            interleaver inst_itl
            (
                .i_clk  (if_m2s.clk),
                .i_rst  (if_m2s.rst),
                .i_data (if_s2m.data),
                .i_dv   (if_s2m.dv),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
            
        end
        "conv_encoder" : begin
        
            conv_encoder cc
            (
                .i_clk  (if_m2s.clk),
                .i_rst  (if_m2s.rst),
                .i_data (if_s2m.data),
                .i_dv   (if_s2m.dv),
                .o_data (if_m2s.data),
                .o_dv   (if_m2s.dv));
            
        end
        default : begin // passthrough
    
            assign if_m2s.data = if_s2m.data;
            assign if_m2s.dv = if_s2m.dv;
        end
    endcase
    
endmodule
