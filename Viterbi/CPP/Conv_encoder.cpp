#include "Conv_encoder.hpp"

using namespace spu;
using namespace spu::module;

Conv_encoder::Conv_encoder(const int K)
    : K(K), Stateful()
{
    // compute the number of outputs of the conv encoder + the number of branch metrics
    // poly_gen = {9, 11, 13};
    poly_gen = {5, 7};
    // poly_gen = {11, 13};
    // poly_gen = {39, 43}; // 47,53 en octal
    // poly_gen = {369, 491}; // 561,753 en octal
    outputs_nb = poly_gen.size(); 
    poly_deg = static_cast<int>(std::log2(poly_gen[0])); //TODO test other polynomials and take the max
    N = outputs_nb * K;
    
    encoding_matrix.resize(outputs_nb, std::vector<int>((1<<(poly_deg+1)), 0));
    
    // build the encoding table
    // k : MSBit: bit to encode and LSByte = current_state
    for(auto k = 0; k < (1<<(poly_deg+1)); k++)
    {
        for(auto i = 0; i < outputs_nb; i++) // for each output of the encoder
        {
            int polynome = poly_gen[i];
            int bit = 0;

            // Apply XOR according to the generator polynomial
            for(auto j = 0; j < poly_deg+1; j++)
            {
                if((polynome >> j) & 1)
                {
                    bit ^= (k >> j) & 1;
                }
            }
            encoding_matrix[i][k] = bit; // store the output of the encoder for the ith output and bit|state k
        }
    }

    for(auto i = 0; i < (1<<(poly_deg+1)); i++)
    {
        std::cout << "i = " << i << " ";
        for(auto j = 0; j < outputs_nb; j++)
        {
            std::cout << encoding_matrix[j][i] << " ";
        }
        std::cout << std::endl;
    }

    std::cout << "poly deg = " << poly_deg << std::endl;

    this->set_name("Conv_encoder");
    this->set_short_name("Conv_encoder");
    
    auto &t = create_task("encode");
    auto input   = create_socket_in<int>(t, "input", K);
    auto output   = create_socket_out<int>(t, "output", N);
    this->create_codelet(t, [input, output](Module &m, runtime::Task &t, const size_t frame_id) -> int {
        static_cast<Conv_encoder&>(m).encode(   static_cast<int*>(t[input].get_dataptr()),
                                                static_cast<int*>(t[output].get_dataptr()),
                                                        frame_id);
        return 0;
    });
    
}

void Conv_encoder::encode(int* input, int* output, const int frame_id)
{
    // Compute the output of the convolutional encoder
    int current_state = 0;
    int mask = (1 << poly_deg) - 1;

    for(auto k = 0; k < K; k++)
    {
        current_state = (input[k]<<poly_deg) | (mask &(current_state >> 1));
        for(auto i = 0; i < outputs_nb; i++)
        {            
            output[k*outputs_nb+i] = encoding_matrix[i][current_state];           
        }
    }
}