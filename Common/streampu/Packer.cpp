#include "Packer.hpp"

using namespace spu;
using namespace spu::module;

Packer::Packer(int frame_size, int packing_ratio)
    : Stateful(), frame_size(frame_size), packing_ratio(packing_ratio)
{
    this->set_name("Packer");
    this->set_short_name("Packer");
    
    auto &t = create_task("pack");
    auto input   = create_socket_in<int>(t, "input", frame_size*packing_ratio);
    auto output   = create_socket_out<int>(t, "output", frame_size);
    this->create_codelet(t, [input, output](Module &m, runtime::Task &t, const size_t frame_id) -> int {
        static_cast<Packer&>(m).pack(   static_cast<int*>(t[input].get_dataptr()),
                                                static_cast<int*>(t[output].get_dataptr()),
                                                        frame_id);
        return 0;
    });

}

void Packer::pack(int* input, int* output, const int frame_id)
{
    for (auto i = 0; i < frame_size; i++)
    {
        for (auto j = 0; j < packing_ratio; j++)
            output[i] = (output[i]<<8) | input[packing_ratio*i + j];
    }
}