// Verilator Example
// Norbertas Kremeris 2021
#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTop.h"
#include "VerilatorSimulation.hpp"

#include <vector>
#include <aff3ct.hpp>

using namespace aff3ct;
using namespace aff3ct::module;

#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>

int main(int argc, char** argv, char** env) {
    
    const int FRAME_SIZE = 20;
    Source_random<> src(FRAME_SIZE);
    
    std::vector<int  > ref_bits;
    ref_bits = std::vector<int  >(FRAME_SIZE);
    src.generate    ( ref_bits );

    VerilatorSimulation sim(FRAME_SIZE);
    sim.simulate(ref_bits, 500);

    src.generate(ref_bits);
    //sim.simulate(ref_bits, 150);


}