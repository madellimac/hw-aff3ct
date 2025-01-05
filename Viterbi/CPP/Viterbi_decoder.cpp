#include "Viterbi_decoder.hpp"

using namespace spu;
using namespace spu::module;

Viterbi_decoder::Viterbi_decoder(const int K)
    : K(K), Stateful()
{
    // compute the number of outputs of the conv encoder + the number of branch metrics
    poly_gen = {5, 7};
    Q_LLR = 4;
    outputs_nb = poly_gen.size();
    BM_nb = 1 << outputs_nb;
    N = outputs_nb * K;

    // generate a matrix containing -1 and 1 for BM computation
    BM_coef.resize(outputs_nb, std::vector<int>(BM_nb, 0));
    for (auto col = 0; col < BM_nb; col++) {
        for (auto row = 0; row < outputs_nb; row++) {
            BM_coef[row][col] = (-2*((col>>row) & 1))+1;
        }
    }

    // create an LLR array
    // std::vector<std::vector<int>> LLRs(outputs_nb, std::vector<int>(K, 0));

    BM.resize(BM_nb, std::vector<int>(K, 0));

    this->set_name("Viterbi_decoder");
    this->set_short_name("Viterbi_decoder");
    
    auto &t = create_task("decode");
    auto input   = create_socket_in<int>(t, "input", N);
    auto output   = create_socket_out<int>(t, "output", K);
    this->create_codelet(t, [input, output](Module &m, runtime::Task &t, const size_t frame_id) -> int {
        static_cast<Viterbi_decoder&>(m).decode(   static_cast<int*>(t[input].get_dataptr()),
                                                static_cast<int*>(t[output].get_dataptr()),
                                                        frame_id);
        return 0;
    });

    

}
void Viterbi_decoder::decode(int* input, int* output, const int frame_id)
{
    
    for (auto i = 0; i < K; i++)
    {
        for(auto j = 0; j < BM_nb; j++)
        {
            BM[j][i] = 0;
            for( auto k = 0; k< outputs_nb; k++)
                BM[j][i] += input[i*outputs_nb+k]*BM_coef[k][j];
        }
    }
    for (auto i = 0; i < K; i++)
    {
        for(auto j = 0; j < BM_nb; j++)
            std::cout << BM[j][i] << " ";
        std::cout << std::endl;
    }

    // for (auto i = 0; i < K; i++)
    // {
    //     output[i] = data_in[i];
    // }
}