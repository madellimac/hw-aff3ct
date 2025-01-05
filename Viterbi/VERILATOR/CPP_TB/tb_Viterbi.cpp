#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTop_Level.h"
#include "VerilatorSimulation.hpp"

#include "MySource.hpp"
#include "SerialPort.hpp"
#include "Comparator.hpp"
#include "Packer.hpp"

#include "Viterbi_decoder.hpp"

#include <vector>
#include <streampu.hpp>
// #include <aff3ct-core.hpp>

using namespace spu;
using namespace spu::module;

#define VERIF_START_TIME 7
vluint64_t sim_time = 0;
vluint64_t posedge_cnt = 0;

#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <random>

int main(int argc, char** argv, char** env) {
    
    const int FRAME_SIZE = 50;
    const int MAX_VAL = 15;
    const int CC_OUTPUT_NB = 2; 
    
    module::MySource            src         (CC_OUTPUT_NB*FRAME_SIZE, MAX_VAL);
    module::Packer              pck         (FRAME_SIZE, CC_OUTPUT_NB);
    module::Viterbi_decoder     sw_vit_dec  (FRAME_SIZE);
    module::Comparator          comp_fpga   (FRAME_SIZE);
    module::Finalizer     <int> finalizer_hw(FRAME_SIZE);
   
    VerilatorSimulation sim(FRAME_SIZE);
    SerialPort serial("/dev/ttyUSB2", 115200, FRAME_SIZE);

    src         ["generate::output" ] = pck        ["pack::input"];
    pck         ["pack::output"]      = sim        ["simulate::input"];
    src         ["generate::output" ] = sw_vit_dec ["decode::input"];
    sw_vit_dec  ["decode::output"   ] = comp_fpga  ["compare::input1"];
    
    sim         ["simulate::output" ] = comp_fpga  ["compare::input2"];

//    src         ["generate::output" ] = serial          ["write::input"];
//    serial      ["write::output"    ] = comp_fpga       ["compare::input2"];
    
    comp_fpga   ["compare::output"  ] = finalizer_hw    ["finalize::in"];

    // std::vector<runtime::Task*> first = {&initializer("initialize")};
    std::vector<runtime::Task*> first = {&src("generate")};
    // std::vector<runtime::Task*> first = {&iter("iterate")};
    runtime::Sequence seq(first);

    std::ofstream file("graph.dot");
    seq.export_dot(file);

    for (auto lt : seq.get_tasks_per_types())
        for (auto t : lt)
        {
            t->set_stats(true);
            t->set_debug(true);
        }

    seq.exec_seq();
    // seq.exec_seq();

}