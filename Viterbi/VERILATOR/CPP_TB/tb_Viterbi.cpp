#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTop_Level.h"
#include "VerilatorSimulation.hpp"

#include "MySource_binary.hpp"
#include "SerialPort.hpp"
#include "Comparator.hpp"
#include "Packer.hpp"

#include "Viterbi_decoder.hpp"
#include "Conv_encoder.hpp"

#include <vector>
#include <streampu.hpp>
#include <aff3ct.hpp>

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
    
    const int FRAME_SIZE = 30;
    const int DATA_WIDTH = 4;
    const int MAX_VAL = 15;
    const int CC_OUTPUT_NB = 2; 
    
    // module::Packer              pck         (FRAME_SIZE, CC_OUTPUT_NB, DATA_WIDTH);
    // module::Viterbi_decoder     sw_vit_dec  (FRAME_SIZE);
    // module::Comparator          comp   (FRAME_SIZE);
    
    aff3ct::module::Modem_BPSK  modem1     (10);
    VerilatorSimulation sim(FRAME_SIZE);
    SerialPort serial("/dev/ttyUSB2", 115200, FRAME_SIZE);
        
    // module::MySource_binary     src         (FRAME_SIZE, DATA_WIDTH);
    // module::Conv_encoder        conv_enc    (FRAME_SIZE);
    // aff3ct::module::Modem_BPSK_fast  <int,float,float> modem       (CC_OUTPUT_NB*FRAME_SIZE, true);
    // module::Finalizer<int>    finalizer_hw(CC_OUTPUT_NB*FRAME_SIZE);

    // src         ["generate::output" ]   = conv_enc      ["encode::input"];
    // conv_enc      ["encode::output"] = finalizer_hw    ["finalize::in"];;
    // conv_enc    ["encode::output"]      = modem[aff3ct::module::mdm::sck::modulate::X_N1];
    // conv_enc    ["encode::output"]      = modem["modulate::X_N1"];
    // modem       ["modulate::X_N2"]      = finalizer_hw  ["finalize::in"];
    // modem       [aff3ct::module::mdm::sck::modulate::X_N2]      = finalizer_hw  ["finalize::in"];

    module::Packer              pck         (FRAME_SIZE, CC_OUTPUT_NB, DATA_WIDTH);
    module::Viterbi_decoder     sw_vit_dec  (FRAME_SIZE);
    module::Comparator          comp   (FRAME_SIZE);
    module::MySource_binary     src         (CC_OUTPUT_NB*FRAME_SIZE, DATA_WIDTH);
    module::Conv_encoder        conv_enc    (FRAME_SIZE);
    module::Finalizer<int>    finalizer_hw(FRAME_SIZE);
    
    src         ["generate::output" ] = pck        ["pack::input"];
    pck         ["pack::output"]      = sim        ["simulate::input"];
    src         ["generate::output" ] = sw_vit_dec ["decode::input"];
    sw_vit_dec  ["decode::output"   ] = comp       ["compare::input1"];
    sim         ["simulate::output" ] = comp       ["compare::input2"];
    comp        ["compare::output"]   = finalizer_hw  ["finalize::in"];
//    src         ["generate::output" ] = serial          ["write::input"];
//    serial      ["write::output"    ] = comp       ["compare::input2"];
    
    // comp   ["compare::output"  ] = finalizer_hw    ["finalize::in"];

    // std::vector<runtime::Task*> first = {&initializer("initialize")};
    std::vector<runtime::Task*> first = {&src("generate")};
    // std::vector<runtime::Task*> first = {&iter("iterate")};
    runtime::Sequence seq(first);

    std::ofstream file("graph.dot");
    seq.export_dot(file);

    

    for (auto lt : seq.get_tasks_per_types())
        for (auto t : lt)
        {
            // t->set_stats(true);
            t->set_debug(true);
        }

    seq.exec_seq();
    // seq.exec_seq();
    // seq.exec_seq();
    // seq.exec_seq();
    
    std::cout << "#" << std::endl;
    
	tools::Stats::show(seq.get_modules_per_types(), true);

}