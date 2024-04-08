#ifndef VERILATORSIMULATION_H
#define VERILATORSIMULATION_H

#include <verilated.h>          // Pour Verilator
#include <verilated_vcd_c.h>    // Pour la trace VCD

class VerilatorSimulation {
public:
    VerilatorSimulation(int frame_size);
    ~VerilatorSimulation();

    void simulate(std::vector<int>& ref_bits, int cycle_count);

private:
    VTop* dut;         // Remplacer "your_module" par le nom de votre module Verilog
    VerilatedVcdC* m_trace;
    vluint64_t sim_time = 0;
    vluint64_t MAX_SIM_TIME = 300;

    int frame_size;

    bool is_reset_time();
    bool is_rising_edge();
    bool is_falling_edge();
};

#endif // VERILATORSIMULATION_H