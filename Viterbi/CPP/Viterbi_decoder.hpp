#ifndef VITERBI_DECODER_HPP
#define VITERBI_DECODER_HPP

#include "streampu.hpp"
#include <iostream>
#include <memory>
#include <array>
#include <thread>

namespace spu
{
namespace module
{

class Viterbi_decoder : public Stateful {

public:

    Viterbi_decoder(const int K);
    void decode(int* input, int* output, const int frame_id);
    
private:

    int encode(int i);
    int K;
    std::vector<int> poly_gen;
    int poly_deg;
    int Q_LLR;
    size_t outputs_nb;
    int SM_nb;
    int BM_nb;
    int N;

    std::vector<std::vector<int>> BM;
    std::vector<std::vector<int>> BM_coef;

    std::vector<std::vector<int>> SM;

};
}
}

#endif // VITERBI_DECODER_HPP
