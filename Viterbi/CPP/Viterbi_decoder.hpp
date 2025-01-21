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
    int N;
    std::vector<int> poly_gen;
    int poly_deg;
    int outputs_nb;

    int Q_LLR;
    int Q_BM;
    int Q_SM;
    int SM_nb;
    int BM_nb;

    std::vector<std::vector<int>> BM;
    std::vector<std::vector<int>> BM_coef;

    std::vector<std::vector<int>> SM;
    std::vector<std::vector<int>> survivor_path;

};
}
}

#endif // VITERBI_DECODER_HPP
