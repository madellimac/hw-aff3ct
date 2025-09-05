#ifndef CONV_ENCODER_HPP
#define CONV_ENCODER_HPP

#include "aff3ct.hpp"
#include "streampu.hpp"

// #include <iostream>
// #include <memory>
// #include <array>
// #include <thread>

namespace spu
{
namespace module
{

class Conv_encoder : public Stateful {

public:

Conv_encoder(const int K);
    void encode(int* input, int* output, const int frame_id);
    
private:

    int K;
    int N;
    std::vector<int> poly_gen;
    int poly_deg;
    int outputs_nb;
    std::vector<int> bits;
    // std::vector<int> encoding_matrix;
    std::vector<std::vector<int>> encoding_matrix;
};
}
}

#endif // CONV_ENCODER_HPP
