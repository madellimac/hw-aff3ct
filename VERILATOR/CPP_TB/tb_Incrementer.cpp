#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTop_Level.h"

#include "VerilatorSimulation.hpp"
#include "MySource.hpp"
#include "Comparator.hpp"

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
#include <random>

int main(int argc, char** argv, char** env) {
    
    const  int FRAME_SIZE = 20;
        
    module::Initializer   <int> initializer(FRAME_SIZE);
    module::Incrementer   <int> incr1(FRAME_SIZE);
    module::Finalizer     <int> finalizer_sw(FRAME_SIZE);
    module::MySource    my_source(FRAME_SIZE);
    module::Comparator comp(FRAME_SIZE);
    VerilatorSimulation sim(FRAME_SIZE);

    
    my_source   ["generate::output" ] = incr1           ["increment::in"];
    my_source   ["generate::output" ] = sim             ["simulate::input"];
    incr1       ["increment::out"   ] = comp            ["compare::input1"];
    sim         ["simulate::output" ] = comp            ["compare::input2"];
    comp        ["compare::output"  ] = finalizer_sw    ["finalize::in"];

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
    seq.exec_seq();

}