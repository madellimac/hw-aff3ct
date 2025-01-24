#include "Viterbi_decoder.hpp"

using namespace spu;
using namespace spu::module;

Viterbi_decoder::Viterbi_decoder(const int K)
    : K(K), Stateful()
{
    // compute the number of outputs of the conv encoder + the number of branch metrics
    // poly_gen = {9, 11, 13};
    poly_gen = {5, 7};
    outputs_nb = poly_gen.size();
    poly_deg = static_cast<int>(std::log2(poly_gen[0]));
    N = outputs_nb * K;
    
    // val Q_BM : Int = 1 + log2Ceil(N_outputs*(1<<Q_LLR))
    // val Q_SM : Int = 1 + log2Ceil(poly_deg*(1<<Q_BM))
    
    Q_LLR = 4;
    Q_BM = 1 + std::log2(outputs_nb*(1<<Q_LLR));
    Q_SM = 1 + std::log2(poly_deg*(1<<Q_BM));
    BM_nb = 1 << outputs_nb;
    SM_nb = 1 << poly_deg;
    
    std::cout << "QLLR=" << Q_LLR << std::endl;
    std::cout << "QBM=" << Q_BM << std::endl;
    std::cout << "QSM=" << Q_SM << std::endl;
    std::cout << "poly deg = " << poly_deg << std::endl;
    std::cout << "BM_nb=" << BM_nb << std::endl;
    std::cout << "SM_nb=" << SM_nb << std::endl;

    // generate a matrix containing -1 and 1 for BM computation
    BM_coef.resize(outputs_nb, std::vector<int>(BM_nb, 0));
    for (auto col = 0; col < BM_nb; col++) {
        for (auto row = 0; row < outputs_nb; row++) {
            BM_coef[row][col] = (-2*((col>>row) & 1))+1;
        }
    }
    BM.resize(BM_nb, std::vector<int>(K, 0));
    SM.resize(SM_nb, std::vector<int>(K+1, 0));
    survivor_path.resize(SM_nb, std::vector<int>(K+1, 0));
    

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
    int output = 0;
    // Compute the output of the convolutional encoder
    for (int i = 0; i < outputs_nb; i++) {
        int polynome = poly_gen[i];
        int bit = 0;

        // Apply XOR according to the generator polynomial
        for (int j = 0; j < poly_deg+1; j++) {
            if ((polynome >> j) & 1) {
                bit ^= (input >> j) & 1;
            }
        }

        // Pack the current bit to the output
        output |= (bit << i);
    }
    return output;
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

    // BM display
    // for (auto i = 0; i < K; i++)
    // {
    //     for(auto j = 0; j < BM_nb; j++)
    //         std::cout << BM[j][i] << " ";
    //     std::cout << std::endl;
    // }

    // SM computation
    // Init first stage
    for(auto j = 0; j < SM_nb; j++)
    {
        SM[j][0] = 0;
        survivor_path[j][0] = 0;
    }
    int prev_st_0, prev_st_1;
    int ix_BM_0, ix_BM_1;
    int cnt = 0;
    int threshold = 1<<(Q_SM-2);
    bool threshold_detect = false;

    
    for (auto i = 1; i < K+1; i++)
    {
        cnt = 0;
        for(auto j = 0; j < SM_nb; j++)
        {
            // prev_st_0 = (j&(~poly_deg))<<1;
            prev_st_0 = (j << 1) & ((1 << poly_deg)-1);
            prev_st_1 = prev_st_0 | 1;
            ix_BM_0 = encode(j << 1);
            ix_BM_1 = encode((j<<1)|1);
            // std::cout << "prev_st_0: " << prev_st_0 << std::endl;
            // std::cout << "prev_st_1: " << prev_st_1 << std::endl;
            // std::cout << "ix_BM_0: " << ix_BM_0 << std::endl;
            // std::cout << "ix_BM_1: " << ix_BM_1 << std::endl;
            if(SM[prev_st_0][i-1] + BM[ix_BM_0][i-1] > SM[prev_st_1][i-1] + BM[ix_BM_1][i-1])
            {
                survivor_path[j][i] = 0;
                SM[j][i] = SM[prev_st_0][i-1] + BM[ix_BM_0][i-1];
            }
            else
            {
                survivor_path[j][i] = 1;
                SM[j][i] = SM[prev_st_1][i-1] + BM[ix_BM_1][i-1];
            }
            if(threshold_detect == true)
                SM[j][i] -= threshold;

            if(SM[j][i] > threshold)
                cnt++;
        }
        
        if(cnt == SM_nb)
            threshold_detect = true;
        else
            threshold_detect = false;
    }
    
    // Display SM and survivor path
    // for (auto i = 0; i < K+1; i++)
    // {
    //     for(auto j = 0; j < SM_nb; j++)
    //         std::cout << SM[j][i] << " ";
    //     std::cout << std::endl;
    // }
    // for (auto i = 0; i < K+1; i++)
    // {
    //     for(auto j = 0; j < SM_nb; j++)
    //         std::cout << survivor_path[j][i] << " ";
    //     std::cout << std::endl;
    // }

    // Compute output starting assuming returning to zero state
    int st_ix = 0;
    int mask = (1 << poly_deg) - 1;
    int dec_threshold = 1 << (poly_deg-1);
    
    for (auto i = K; i > 0; i--)
    {
        if(st_ix < dec_threshold)
        {
            output[i-1] = 0;
        }
        else
        {
            output[i-1] = 1;
        }
        st_ix = ((st_ix << 1) | survivor_path[st_ix][i]) & mask;        
    }
    // Display output
    // std::cout << std::endl;
    // for(auto i = 0; i < K; i++)
    //     std::cout << output[i] << " ";
    

}