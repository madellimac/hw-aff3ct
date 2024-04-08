

interface if_socket_to_module #(parameter DATA_WIDTH = 8) (input logic clk, rst);

    logic [DATA_WIDTH-1:0] data;
    logic dv;
    logic full;    
    logic rd_en;
    
    //modport mod_socket (input rd_en, output data, dv, full);
    //modport mod_module (input data, dv, full, output rd_en);
    
    typedef struct {
    int MAX_VAL;
    } param_counter;
    
    param_counter P_COUNTER;

endinterface


