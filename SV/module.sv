`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.11.2022 15:25:16
// Design Name: 
// Module Name: module
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


module mod
 #( parameter IN_LENGTH  = 16,
    parameter OUT_LENGTH = 16,
    parameter NB_INPUT_PROCESS  = 1,
    parameter NB_OUTPUT_PROCESS = 1 )
  (
    input logic                             clk     ,
    input logic     [0:IN_LENGTH-1][31:0]   idata   ,
    input logic     /*[IN_LENGTH-1:0]*/         ien_data,
    input logic                             ien     ,
    input logic                             fct     ,
    output logic    [0:OUT_LENGTH-1][31:0]  odata   ,
    output logic                            oen     ,
    output logic                            full
    );
    
    integer i;
    integer j;
    integer k;
    integer l;
    integer m;
    
    
    // input registers
    logic [1:0][0:IN_LENGTH-1][31:0] data;
    logic [1:0]/*[IN_LENGTH-1:0]*/   data_check = 0;
    logic [1:0]                      en_check = 0;
    
    // output registers
    logic [0:OUT_LENGTH-1][31:0] out_data;
    logic [OUT_LENGTH-1:0] out_en = 0;
    logic [OUT_LENGTH-1:0] out_en_reg = 0;
    
    // control unit input
    logic [1:0] en_fct;
    logic output_enable; // ????
    
    // control unit output
    logic [15:0] input_control = 0;
    logic [15:0] output_control = 0;
    logic input_enable = 0;
    
    // function inputs
    logic in_en_fct;
    assign in_en_fct = input_enable;
    logic [0:NB_INPUT_PROCESS-1][31:0] in_data_fct;
    
    // function outputs
    logic out_en_fct;
    assign output_enable = out_en_fct;
    logic [0:NB_OUTPUT_PROCESS-1][31:0] out_data_fct;
    
    logic in_progress = 0;
    
    
    ///// ping pong memory control /////
//    logic [1:0] memory_full = 0;
    logic memory_select = 0;
    
    
//    // input registers bis
//    logic [0:IN_LENGTH-1][31:0] data_bis;
//    logic /*[IN_LENGTH-1:0]*/   data_check_bis = 0;
//    logic                       en_check_bis = 0;
    
    
    ////////////////////////////////////
    
    assign en_fct[0] = en_check[0] & /*&*/data_check[0];
    assign en_fct[1] = en_check[1] & /*&*/data_check[1];
    assign oen = &out_en_reg & !fct;
    
    assign full = en_fct[!memory_select];
    
    
    funct #(
        .NB_INPUT   (NB_INPUT_PROCESS   ),
        .NB_OUTPUT  (NB_OUTPUT_PROCESS  )
    )funct (
        .clk            (clk            ),
        .in_en_fct      (in_en_fct      ),
        .in_data_fct    (in_data_fct    ),
        .out_en_fct     (out_en_fct     ),
        .out_data_fct   (out_data_fct   )
    );
    
    
    // input registers treatment
    always_ff @(posedge clk)
    begin
//        for(i = 0 ; i < IN_LENGTH ; i++) begin
//            if (en_fct) begin
//                en[i] <= 0;
//            end
//            else if(ien_data[i]) begin
//                data[i] <= idata[i];
//                en[i] <= ien_data[i];
//            end
//        end
        if(en_fct[memory_select]) begin
            data_check[memory_select] <= 0;
            en_check[memory_select] <= 0;
        end
        else begin
            if(ien_data) begin
                if (!in_progress) begin
                    data_check[memory_select] <= 1;
                    for(j = 0 ; j < IN_LENGTH ; j++) begin
                        data[memory_select][j] <= idata[j];
                    end
                end
                else begin
                    data_check[!memory_select] <= 1;
                    for(j = 0 ; j < IN_LENGTH ; j++) begin
                        data[!memory_select][j] <= idata[j];
                    end
                end
            end
            if (ien) begin
                if (!in_progress) begin
                    en_check[memory_select] <= 1;
                end
                else begin
                    en_check[!memory_select] <= 1;
                end
            end
        end
    end
    
    
    
    // output registers treatment
    always_ff @(posedge clk)
    begin
        for(k = 0 ; k < OUT_LENGTH ; k++) begin
            if (oen) begin
                out_en_reg[k] <= 0;
                if (en_fct[!memory_select]) begin
                    memory_select <= !memory_select;
                end
            end
            else if(out_en[k]/* && output_control == i*/) begin
                odata[k] <= out_data[k];
                out_en_reg[k] <= 1;
            end
        end
//        if(oen) begin
//            out_en_reg <= 0;
//            odata <= out_data;
//        end
    end
    
    always_comb
    begin
        for(i = 0 ; i < OUT_LENGTH ; i+=NB_OUTPUT_PROCESS) begin
            if (i == output_control) begin
                for ( m = 0 ; m < NB_OUTPUT_PROCESS ; m++ ) begin
                    out_data[i+m] = out_data_fct[m];
                    out_en[i+m] = out_en_fct;
                end
            end
            else begin
                for ( m = 0 ; m < NB_OUTPUT_PROCESS ; m++ ) begin
                    out_data[i+m] = 0;
                    out_en[i+m] = 0;
                end
            end
        end
    end
    
    
    always_comb
    begin
        for( int l = 0 ; l < NB_INPUT_PROCESS ; l++ ) begin
            in_data_fct[l] = data[memory_select][input_control+l];
        end
    end
    
    // CONTROL UNIT
    // in progress control
    always_ff @(posedge clk)
    begin
        if (en_fct[memory_select]) begin
            in_progress <= 1;
            input_enable <= 1;
        end
        else if (input_control == IN_LENGTH-NB_INPUT_PROCESS && output_control == OUT_LENGTH-NB_OUTPUT_PROCESS) begin
            in_progress <= 0;
            input_enable <= 0;
        end
        else if (output_enable & in_progress) begin
            input_enable <= 1;
        end
        else begin
            input_enable <= 0;
        end
    end
    
    // data processed control
    always_ff @(posedge clk)
    begin
        if (output_enable) begin
//            if ( (OUT_LENGTH == IN_LENGTH) || (OUT_LENGTH < IN_LENGTH) ) begin
//                if (output_control == OUT_LENGTH-1) begin
//                    output_control <= 0;
//                end
//                else begin
//                    output_control <= output_control + 1;
//                end
//            end
//            else begin
//                if (output_control == OUT_LENGTH-OUT_LENGTH/IN_LENGTH) begin
//                    output_control <= 0;
//                end
//                else begin
//                    output_control <= output_control + OUT_LENGTH/IN_LENGTH;
//                end
//            end
            if (output_control == OUT_LENGTH-NB_OUTPUT_PROCESS) begin
                output_control <= 0;
            end
            else begin
                output_control <= output_control + NB_OUTPUT_PROCESS;
            end
        end
        else if (input_enable) begin
//            if ( (OUT_LENGTH == IN_LENGTH) || (OUT_LENGTH > IN_LENGTH) ) begin
//                if (input_control == IN_LENGTH-1) begin
//                    input_control <= 0;
//                end
//                else begin
//                    input_control <= input_control + 1;
//                end
//            end
//            else begin
//                if (input_control == IN_LENGTH-IN_LENGTH/OUT_LENGTH) begin
//                    input_control <= 0;
//                end
//                else begin
//                    input_control <= input_control + IN_LENGTH/OUT_LENGTH;
//                end
//            end
            if (input_control == IN_LENGTH-NB_INPUT_PROCESS) begin
                input_control <= 0;
            end
            else begin
                input_control <= input_control + NB_INPUT_PROCESS;
            end
        end
    end
    
endmodule
