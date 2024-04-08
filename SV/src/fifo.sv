`timescale 1ns / 1ps

module fifo #(parameter DEPTH = 4)(
     if_module_to_socket if_m2s,
     if_socket_to_module if_s2m);

    localparam DATA_WIDTH = if_m2s.DATA_WIDTH;

    // Déclaration du tableau de stockage des données
    logic [DATA_WIDTH-1:0] fifo [DEPTH-1:0];

    // Déclaration des pointeurs de lecture et écriture
    logic [$clog2(DEPTH):0] wr_ptr, rd_ptr;
    logic [$clog2(DEPTH):0] data_count;

    // Logique de contrôle
   
    always_ff @(posedge if_m2s.clk or posedge if_m2s.rst) begin
        if (if_m2s.rst) begin
            wr_ptr <= 0;
            fifo[DEPTH-1:0] <= '{DEPTH{0}};
        end else begin
            if (if_m2s.dv && !if_s2m.full) begin
                if(wr_ptr == DEPTH-1) begin
                    fifo[wr_ptr] <= if_m2s.data;
                    wr_ptr <= 0;
                end else begin
                    fifo[wr_ptr] <= if_m2s.data;
                    wr_ptr <= wr_ptr + 1;
                end             
            end           
        end
    end

    // Logique de contrôle
    always_ff @(posedge if_m2s.clk or posedge if_m2s.rst) begin
        if (if_m2s.rst) begin
            rd_ptr <= 0;
            if_s2m.dv <= 0;
            if_s2m.data <= 0;
        end else begin
            if (if_s2m.rd_en && !if_m2s.empty) begin
                if(rd_ptr == DEPTH-1) begin
                    if_s2m.data <= fifo[rd_ptr];
                    if_s2m.dv <= 1;
                    rd_ptr <= 0;
                end else begin
                    if_s2m.data <= fifo[rd_ptr];
                    if_s2m.dv <= 1;
                    rd_ptr <= rd_ptr + 1;
                end
            end else begin
                if_s2m.data <= fifo[rd_ptr];
                if_s2m.dv <= 0;
                rd_ptr <= rd_ptr;            
            end
        end
    end
    
    always_ff @(posedge if_m2s.clk or posedge if_m2s.rst) begin
        if (if_m2s.rst) begin
            data_count <= 0;
        end else begin
            if (if_s2m.rd_en && !if_m2s.dv) begin
                data_count <= data_count -1;
            end else if(!if_s2m.rd_en && if_m2s.dv) begin
                data_count <= data_count +1;             
            end else begin
                data_count <= data_count;
            end
        end
    end
    
    assign if_s2m.full = (data_count == DEPTH);
    assign if_m2s.empty = (data_count == 0);
    

endmodule

