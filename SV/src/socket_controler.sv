`timescale 1ns / 1ps 
 
module socket_controler #(parameter MAX_DATA_COUNT = 4)( 
    input logic  i_clk, 
    input logic  i_rst, 
    input logic  i_full, 
    input logic  i_empty, 
     
    output logic o_rd_en);
 
    logic init_data_count;
    logic [$clog2(MAX_DATA_COUNT)-1:0] data_count; 
    logic dummy;
 
    counter #(.MAX_VAL(MAX_DATA_COUNT)) data_counter (   .i_clk  (i_clk),
                                            .i_rst  (i_rst),
                                            .i_init (init_data_count),
                                            .i_dv   (o_rd_en),
                                            .o_data (data_count),
                                            .o_dv   (dummy));
                                        
    typedef enum { st_wait , st_pull } t_state; 
 
    t_state current_state, next_state; 
 
    always_ff @ ( posedge i_clk , posedge i_rst ) 
        if ( i_rst ) 
            current_state <= st_wait; 
        else 
            current_state <= next_state ; 
                 
    always_comb begin 
        next_state = current_state ; // default state : the same 
        o_rd_en = 1'b0; 
        init_data_count = 0;
        unique case ( current_state ) 
            st_wait : begin        
                o_rd_en = 1'b0;
                init_data_count = 1'b1;
                if ( i_empty == 1'b0 | i_full == 1'b0 ) 
                    next_state = st_wait;
                else 
                    next_state = st_pull; 
            end 
            st_pull : begin 
                o_rd_en = 1'b1 ; 
                init_data_count = 1'b0;
                if ( data_count < MAX_DATA_COUNT-1 ) 
                    next_state = st_pull;
                else
                    next_state = st_wait;
            end
        endcase
    end
endmodule
