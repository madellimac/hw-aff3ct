#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <verilated.h>
#include <verilated_vcd_c.h>
#include "VTop2.h"
#include "VerilatorSimulation.hpp"

#include <vector>
// #include <aff3ct.hpp>
#include <aff3ct-core.hpp>

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
    
    const int FRAME_SIZE = 20;
        
    module::Initializer<int> initializer(FRAME_SIZE);
    module::Incrementer<int> incr1(FRAME_SIZE);
    module::Incrementer<int> incr2(FRAME_SIZE);
    module::Finalizer<int> finalizer_sw(FRAME_SIZE);
    module::Finalizer<int> finalizer_hw(FRAME_SIZE);
     
    // VTop2 *dut = new VTop2;
    // dut = new VTop2;

    VerilatorSimulation<VTop2> sim(FRAME_SIZE);


    initializer["initialize::out"] = incr1["increment::in"];
    incr1["increment::out"] = incr2["increment::in"];
    incr2["increment::out"] = finalizer_sw["finalize::in"];

    initializer["initialize::out"] = sim["simulate::input"];
    sim["simulate::output"] = finalizer_hw["finalize::in"];

    std::vector<runtime::Task*> first = {&initializer("initialize")};
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