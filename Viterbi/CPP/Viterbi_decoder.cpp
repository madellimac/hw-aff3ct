#include "Viterbi_decoder.hpp"

using namespace spu;
using namespace spu::module;

Viterbi_decoder::Viterbi_decoder(const int K)
    : K(K), Stateful()
{
    // compute the number of outputs of the conv encoder + the number of branch metrics
    poly_gen = {5, 7};
    poly_deg = static_cast<int>(std::log2(poly_gen[0]));
    std::cout << "poly deg = " << poly_deg << std::endl;
    Q_LLR = 4;
    outputs_nb = poly_gen.size();
    BM_nb = 1 << outputs_nb;
    SM_nb = 1 << poly_deg;
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
    SM.resize(SM_nb, std::vector<int>(K, 0));

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

int Viterbi_decoder::encode(int input)
{
    int bitsSortie = 0;
    // Calculer les bits de sortie pour chaque polynôme
    for (size_t i = 0; i < outputs_nb; i++) {
        int polynome = poly_gen[i];
        int bitSortie = 0;

        // Appliquer XOR selon les positions des bits actifs dans le polynôme
        for (int j = 0; j < poly_deg+1; j++) {
            if ((polynome >> j) & 1) { // Vérifier si le bit j du polynôme est actif
                bitSortie ^= (input >> j) & 1;
            }
        }


        // Ajouter le bit de sortie au bon emplacement
        bitsSortie |= (bitSortie << i);
    }
    return bitsSortie;
}
void Viterbi_decoder::decode(int* input, int* output, const int frame_id)
{
    // BM computation
    for (auto i = 0; i < K; i++)
    {
        for(auto j = 0; j < BM_nb; j++)
        {
            BM[j][i] = 0;
            for( auto k = 0; k < outputs_nb; k++)
                BM[j][i] += input[i*outputs_nb+k]*BM_coef[k][j];
        }
    }

    // for (auto i = 0; i < K; i++)
    // {
    //     for(auto j = 0; j < BM_nb; j++)
    //         std::cout << BM[j][i] << " ";
    //     std::cout << std::endl;
    // }
    // for(auto i = 0; i < 2*SM_nb; i++)
    // {
    //     std::cout << " " << i << "enc :" << encode(i) << std::endl;
    // }
    // std::cout << std::endl;
    // SM computation

    // Init first stage
    for(auto j = 0; j < SM_nb; j++)
    {
        SM[j][0] = 0;
    }

    int prev_st_0, prev_st_1;
    int ix_BM_0, ix_BM_1;
    for (auto i = 1; i < K; i++)
    {
        for(auto j = 0; j < SM_nb; j++)
        {
            prev_st_0 = (j&(~poly_deg))<<1;
            prev_st_1 = prev_st_0 | 1;
            // std::cout << prev_st_0 << " "<< prev_st_1 << std::endl;
            ix_BM_0 = encode(j << 1);
            ix_BM_1 = encode((j<<1)|1);
            // std::cout << ix_BM_0 << " "<< ix_BM_1 << std::endl;
            SM[j][i] = std::max( SM[prev_st_0][i-1] + BM[ix_BM_0][i-1], SM[prev_st_1][i-1] + BM[ix_BM_1][i-1]);
        }
    }
    for (auto i = 0; i < K; i++)
    {
        for(auto j = 0; j < SM_nb; j++)
            std::cout << SM[j][i] << " ";
        std::cout << std::endl;
    }



}