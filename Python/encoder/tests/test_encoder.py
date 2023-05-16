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
    # get the frozen bits depending on k and N
    frozen_bits = frozen.get_frozen_bits(K, N)
    
    #Pyaff3ct encoder
    #numpy array bits
    bits_np = np.array(bits, ndmin = 2, dtype=np.int32)
    enc =  polar_encoder.Encoder_polar(K, N, frozen_bits) # Build the encoder
    enc["encode::U_K"] = bits_np # Set the input data
    enc['encode'].exec()

    # My encoder
    encoded_bits = my_encoder.encode(bits, frozen_bits)

    # compare the output of the two encoder
    for i in range(N):
        if(enc["encode::X_N"][0][i] != encoded_bits[i]):
            print("error")
            print("aff3ct: " + enc["encode::X_N"][0])
            print("My encoder: " + encoded_bits)
            break  

# function to test the char encoder
def test_encoder_char(char:chr):
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
    encoded_bits = my_encoder.encode_char(char)

    # compare the output of the two encoder
    for i in range(N):
        if(enc["encode::X_N"][0][i] != encoded_bits[i]):
            print("error")
            print("aff3ct: " + enc["encode::X_N"][0])
            print("My encoder: " + encoded_bits)
            break  

def launch_test():
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
