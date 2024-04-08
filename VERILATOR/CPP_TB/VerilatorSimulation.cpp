#include <stdlib.h>
#include <iostream>
#include <verilated.h>          // Pour Verilator
#include "VTop.h"       // Remplacer "your_module" par le nom de votre module Verilog
#include "VerilatorSimulation.hpp"


    VerilatorSimulation::VerilatorSimulation(int frame_size) : frame_size(frame_size){
        dut = new VTop;  // Remplacer "your_module" par le nom de votre module Verilog
        Verilated::traceEverOn(true);
        m_trace = new VerilatedVcdC;
        dut->trace(m_trace, 5);
        m_trace->open("waveform.vcd");
    }

    VerilatorSimulation::~VerilatorSimulation() {
        m_trace->close();
        delete m_trace;
        delete dut;
        // exit(EXIT_SUCCESS);
    }

    void VerilatorSimulation::simulate(std::vector<int>& ref_bits, int cycle_count) {
        
        int input_data_count = 0;
        int output_data_count = 0;

        enum t_state { wait, shift_in, shift_out, over };
        t_state c_state, n_state = wait;
        int i =0;
        int init_time = sim_time;
        int val;

        std::cout << " new sim ";

        // while (sim_time < init_time+cycle_count) {
        while(output_data_count < frame_size) {
            
            if(is_reset_time()){
                dut->reset = 1;
                dut->io_i_ready = 0;
            }
            else if(is_rising_edge()){
                dut->reset = 0;       
                c_state = n_state;     
            }
            else if(is_falling_edge()){
                dut->reset = 0;
                switch(c_state) {
                    case wait :
                        if(dut->io_o_ready == 1) n_state = shift_in;
                        else n_state = wait;
                        break;
                    case shift_in :
                        if(input_data_count == frame_size-1) n_state = shift_out;
                        else n_state = shift_in;
                        break;
                    case shift_out :
                        if(output_data_count == frame_size) n_state = over;
                        else n_state = shift_out;
                        break;
                    case over :
                        n_state = over;
                        break;
                }

                switch(c_state) {
                    case wait :
                        dut->io_i_dv    = 0;
                        dut->io_i_ready = 1;
                        input_data_count = 0;
                        output_data_count = 0;
                        break;
                    case shift_in :
                        dut->io_i_ready = 0;
                        dut->io_i_dv    = 1;
                        std::cout << ref_bits[input_data_count] << " ";
                        dut->io_i_data  = ref_bits[input_data_count++];
                        break;
                    case shift_out :
                        dut->io_i_dv    = 0;
                        dut->io_i_ready = 1;
                        val = dut->io_o_data;
                        if(dut->io_o_dv == 1) {
                            std::cout << val << " ";
                            output_data_count++;                    
                        }
                        break;
                    case over :
                        dut->io_i_dv    = 0;
                        dut->io_i_ready = 0;
                        input_data_count = 0;
                        output_data_count = 0;
                        break;
                }  
            }
            
            dut->clock ^= 1;
            dut->eval();

            m_trace->dump(sim_time);

            sim_time++;
           
        }
        std::cout << std::endl;
    }

    // Ajoutez d'autres méthodes pour contrôler votre simulation au besoin


    bool VerilatorSimulation::is_reset_time(){
        return (sim_time < 7);
    }

    bool VerilatorSimulation::is_rising_edge(){
        return (sim_time%2 == 0);
    }

    bool VerilatorSimulation::is_falling_edge(){
        return (sim_time%2 != 0);
    }

