from typing import List

# Import the python encoder
import encoder as my_encoder
# Import the vhdl encoder
import vhdl_encoder

# function that takes an array of char in parameter 

def compare_char_encoder(data_in: List[chr]):
    """Function that get the encoded char values from the python encoder and vhdl encoder and compare them
    for a given list of char

    Args:
        data_in (List[chr]): list of char to encode
    """

    N=16 # for a char, the encoded output is 16 bits

    for chr in data_in:
        # My encoder
        encoded_bits = my_encoder.encode_char(chr)

        # vhdl encoder
        encoded_bits_vhdl = vhdl_encoder.encode_char(data_in)

        # compare the output of the two encoder
        for i in range(N):
            if(encoded_bits_vhdl[i] != encoded_bits[i]):
                print("error")
                print("vhdl: " + encoded_bits_vhdl)
                print("My encoder: " + encoded_bits)
                break

