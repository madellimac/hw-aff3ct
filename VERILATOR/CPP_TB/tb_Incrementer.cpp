#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTop_Level.h"

#include "VerilatorSimulation.hpp"
#include "MySource.hpp"
#include "Comparator.hpp"
#include "SerialPort.hpp"

#include <vector>
#include <streampu.hpp>

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
    module::Finalizer     <int> finalizer_sw(FRAME_SIZE);
    module::Finalizer     <int> finalizer_hw(FRAME_SIZE);
    module::MySource    my_source(FRAME_SIZE);
    module::Comparator comp_sim(FRAME_SIZE);
    module::Comparator comp_fpga(FRAME_SIZE);
    VerilatorSimulation sim(FRAME_SIZE);
    // SerialPort serial("/dev/tty.usbserial-210292ABF7641", 115200, FRAME_SIZE); 
    SerialPort serial("/dev/ttyUSB2", 115200, FRAME_SIZE); 

    
    my_source   ["generate::output" ] = incr1           ["increment::in"];
    my_source   ["generate::output" ] = sim             ["simulate::input"];
    my_source   ["generate::output" ] = serial          ["write::input"];

    incr1       ["increment::out"   ] = comp_sim            ["compare::input1"];
    sim         ["simulate::output" ] = comp_sim            ["compare::input2"];
    comp_sim    ["compare::output"  ] = finalizer_sw        ["finalize::in"];

    incr1       ["increment::out" ]   = comp_fpga            ["compare::input1"];
    serial      ["write::output"   ]   = comp_fpga            ["compare::input2"];
    comp_fpga   ["compare::output"  ] = finalizer_hw        ["finalize::in"];

    std::vector<runtime::Task*> first = {&my_source("generate")};
    
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