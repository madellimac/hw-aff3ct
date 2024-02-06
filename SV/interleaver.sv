`timescale 1ns / 1ps

module interleaver(
    input logic i_clk,
    input logic i_rst,
    input logic i_data,
    input logic i_dv,
    output logic o_data,
    output logic o_dv
    );
    
    logic [2:0] en_counter;
    logic reg_1;
    logic [1:0] reg_2;
    logic [2:0] reg_3;
    logic [3:0] reg_4;
    logic [4:0] reg_5;
    logic [5:0] reg_6;
    
    assign o_dv = i_dv;
        
    always_ff @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
            en_counter <= 0;
        end else if (i_dv) begin
            if (en_counter == 6) begin
                en_counter <= 0;
            end else begin
                en_counter <= en_counter + 1;
            end
        end else begin
            en_counter <= en_counter;
        end
    end
    
    always_comb begin
        case (en_counter)
            0 : o_data = i_data;
            1 : o_data = reg_1;
            2 : o_data = reg_2[1];
            3 : o_data = reg_3[2];
            4 : o_data = reg_4[3];
            5 : o_data = reg_5[4];
            6 : o_data = reg_6[5];
            default: o_data = 0;
        endcase
    end
        
    always_ff @(posedge i_clk or posedge i_rst) begin
            if (i_rst) begin
                reg_1 <= 0;
                reg_2 <= 0;
                reg_3 <= 0;
                reg_4 <= 0;
                reg_5 <= 0;
                reg_6 <= 0;
            end else if (i_dv) begin
                case (en_counter)
                    1 : reg_1 <= i_data;
                    2 : reg_2 <= {reg_2[0], i_data};
                    3 : reg_3 <= {reg_3[1:0], i_data};
                    4 : reg_4 <= {reg_4[2:0], i_data};
                    5 : reg_5 <= {reg_5[3:0], i_data};
                    6 : reg_6 <= {reg_6[4:0], i_data};
                    default: reg_1 <= reg_1;// no action for other cases
                endcase
            end
        end   
    
endmodule
