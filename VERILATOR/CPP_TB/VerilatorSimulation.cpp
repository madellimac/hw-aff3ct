#include <stdlib.h>
#include <iostream>
#include <verilated.h>          
#include "VTop_Level.h"       
#include "VerilatorSimulation.hpp"

using namespace spu;
using namespace spu::module;

    VerilatorSimulation::VerilatorSimulation(int frame_size) : Module(), frame_size(frame_size) {

        dut = new VTop_Level;  // Remplacer "your_module" par le nom de votre module Verilog

        Verilated::traceEverOn(true);
        m_trace = new VerilatedVcdC;
        dut->trace(m_trace, 5);
        m_trace->open("waveform.vcd");
        
        this->set_name("VerilatorSimulation");
        this->set_short_name("VerilatorSimulation");

        auto &t = create_task("simulate");

        auto input    = create_socket_in<int>(t, "input", frame_size);
        auto output   = create_socket_out<int>(t, "output", frame_size);

        this->create_codelet(t, [input, output](Module &m, runtime::Task &t, const size_t frame_id) -> int {
        static_cast<VerilatorSimulation&>(m).simulate(  static_cast<int*>(t[input].get_dataptr()),
                                                        static_cast<int*>(t[output].get_dataptr()),
                                                        frame_id);
        return 0;
    });

    }

    VerilatorSimulation::~VerilatorSimulation() {
        m_trace->close();
        delete m_trace;
        delete dut;
        // exit(EXIT_SUCCESS);
    }    

    void VerilatorSimulation::simulate(const int* input, int *output, const int frame_id) {
        
        int input_data_count = 0;
        int output_data_count = 0;

        enum t_state { wait, shift_in, shift_out, over };
        t_state c_state, n_state = wait;
        int i =0;
        int init_time = sim_time;
        int val;

        // while (sim_time < 10000) {
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
                        dut->io_i_dv    = 1;
                        dut->io_i_ready = 0;
                        std::cout << input[input_data_count] << " ";
                        dut->io_i_data  = input[input_data_count++];
                        break;
                    case shift_out :
                        dut->io_i_dv    = 0;
                        dut->io_i_ready = 1;
                        val = dut->io_o_data;
                        if(dut->io_o_dv == 1) {
                            std::cout << val << " ";
                            output[output_data_count] = val;
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