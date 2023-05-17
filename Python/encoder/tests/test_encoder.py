"""    Compare the output of the encoder with the output of the aff3ct encoder
"""
aff3ct_path = "/mnt/d/OneDrive/Etude/Enseirb/Projet S8/py_aff3ct/build/lib"

import sys

sys.path.insert(0, aff3ct_path)
sys.path.insert(0, '../')
import numpy as np
import time
import math
import matplotlib.pyplot as plt

import py_aff3ct
import py_aff3ct.tools.frozenbits_generator as tool_fb
import py_aff3ct.tools.noise as tool_noise
import py_aff3ct.module.encoder as polar_encoder


import encoder as my_encoder
import frozen_bits_generator as frozen



# Create 
def test_encoder_pyaff3ct(bits, K, N):
    """
    Compare the encoded value of the aff3ct encoder and
    this encoder.

    Print the error if any

    Args:
        bits (array bits (int)): the array of bits to encode
        K (int): the number of bits to encode  
        N (int): the number of encoded bits
    """

    # get the frozen bits depending on k and N
    frozen_bits = frozen.get_frozen_bits(K, N)
    
    #Pyaff3ct encoder
    #numpy array bits
    bits_np = np.array(bits, ndmin = 2, dtype=np.int32)
    enc =  polar_encoder.Encoder_polar(K, N, frozen_bits) # Build the encoder
    enc["encode::U_K"] = bits_np # Set the input data
    enc['encode'].exec()

    # My encoder
    my_enc = my_encoder.polar_encoder(frozen_bits)
    encoded_bits = my_enc.encode(bits) 
    # compare the output of the two encoder
    for i in range(N):
        if(enc["encode::X_N"][0][i] != encoded_bits[i]):
            print("error in the encoder")
            print("aff3ct: " + enc["encode::X_N"][0])
            print("My encoder: " + encoded_bits)
            sys.exit()
            break  

# function to test the char encoder
def test_encoder_char(char:chr):
    """
    Compare the encoded value of the aff3ct encoder and
    this encoder for a char (8 bits)

    Args:
        char (chr): the 8 bits to encode
    """

    K=8
    N=16
    # get the frozen bits depending on k and N
    frozen_bits = frozen.get_frozen_bits(K, N)
    
    # get the bits of the char
    bits = [int(x) for x in list('{0:08b}'.format(ord(char)))]
    
    #Pyaff3ct encoder
    #numpy array bits
    bits_np = np.array(bits, ndmin = 2, dtype=np.int32)
    enc =  polar_encoder.Encoder_polar(K, N, frozen_bits) # Build the encoder
    enc["encode::U_K"] = bits_np # Set the input data
    enc['encode'].exec()

    # My encoder
    my_enc = my_encoder.polar_encoder(frozen_bits)
    encoded_bits = my_enc.encode_char(char)

    # compare the output of the two encoder
    for i in range(N):
        if(enc["encode::X_N"][0][i] != encoded_bits[i]):
            print("error in the char encoder")
            print("aff3ct: " + enc["encode::X_N"][0])
            print("My encoder: " + encoded_bits)
            sys.exit()
            break  

def launch_test():
    """
    Launch the tests for k=8 and N=16. For each value
    possible for k (k=8 --> 256), it encodes the data with
    this encoder and compares it with the aff3ct encoder.
    
    Prints the error if any. Otherwise, display nothing 
    """

    # test all posible input to compare the two encoder
    K=8
    N=16
    for i in range(2**K):
        bits = [int(x) for x in list('{0:0b}'.format(i))]
        bits = [0]*(K-len(bits)) + bits
        test_encoder_pyaff3ct(bits, K, N)


    # test different char for the char encoder
    test_encoder_char('a')
    test_encoder_char('b')
    test_encoder_char('c')
    test_encoder_char('d')
    test_encoder_char('e')
    test_encoder_char('f')
    test_encoder_char('g')


def encode_char_to_file():   
    """
    Generate all char (256 character) in the polar encoded format
    and save them in the file /text_file/encoded_char.txt
    """

    # open the file
    file = open("../text_files/encoded_char.txt", "w")

    for(char) in range(256):
        # get the bits of the char
        #bits = [int(x) for x in list('{0:08b}'.format(char))]
        
        # My encoder
        encoded_bits = my_encoder.encode_char(chr(char))

        # write the encoded bits
        file.write(str(char) + " : ")
        for(bit) in encoded_bits:
            file.write(str(bit))
        file.write("\n")

    # close the file
    file.close()


if __name__ == '__main__':
    launch_test()
    #encode_char_to_file()
