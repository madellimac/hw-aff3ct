
import sys
#sys.path.insert(0, '/./../py_aff3ct/build/lib')
sys.path.insert(0, '/mnt/d/OneDrive/Etude/Enseirb/Projet S8/py_aff3ct/build/lib')
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

# Generate frozen bits from K=4 and N=8
K=8
N=16

# Create 
def test_encoder_pyaff3ct(bits):
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

# test all posible input to compare the two encoder
for i in range(2**K):
    bits = [int(x) for x in list('{0:0b}'.format(i))]
    bits = [0]*(K-len(bits)) + bits
    test_encoder_pyaff3ct(bits)

# test_encoder_pyaff3ct([0,1])
# test_encoder_pyaff3ct([1,1])
