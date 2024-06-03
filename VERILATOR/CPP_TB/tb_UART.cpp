#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTop_Level.h"
#include "VerilatorSimulation.hpp"
#include "SerialPort.hpp"

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
    
    const  int FRAME_SIZE = 20;
        
    module::Initializer   <int> initializer(FRAME_SIZE);
    module::Incrementer   <int> incr1(FRAME_SIZE);
    module::Incrementer   <int> incr2(FRAME_SIZE);
    module::Finalizer     <int> finalizer_sw(FRAME_SIZE);
    module::Finalizer     <int> finalizer_hw(FRAME_SIZE);
    module::Source_random <int> src(FRAME_SIZE); 
    SerialPort serial("/dev/tty.usbserial-210292ABF7641", 115200, FRAME_SIZE); 

    VerilatorSimulation sim(FRAME_SIZE);
    
    // iter["iterate::out"]= incr1["increment::in"];
    src["generate::out_data"] = incr1["increment::in"];
    // initializer["initialize::out"] = incr1["increment::in"];
    incr1["increment::out"] = finalizer_sw["finalize::in"];

    src["generate::out_data"] = sim["simulate::input"];
    // initializer["initialize::out"] = sim["simulate::input"];
    sim["simulate::output"] = serial["write::input"];

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
    seq.exec_seq();

}