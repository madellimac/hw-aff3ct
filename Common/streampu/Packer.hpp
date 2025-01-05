#ifndef PACKER_HPP
#define PACKER_HPP

#include "streampu.hpp"

namespace spu
{
namespace module
{

class Packer : public Stateful {

public:

    Packer(int frame_size, int packing_ratio);
    void pack(int* input, int* output, const int frame_id);
    
private:

    int frame_size;
    int packing_ratio;
    
};
}
}

#endif // SERIALPORT_HPP
