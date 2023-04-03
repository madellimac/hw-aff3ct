import sys
sys.path.insert(0, '../../py_aff3ct/build/lib')
import numpy as np
import time
import math
import matplotlib.pyplot as plt

import py_aff3ct
import py_aff3ct.tools.frozenbits_generator as tool_fb
import py_aff3ct.tools.noise as tool_noise
import py_aff3ct.module.encoder as polar_encoder

# function get the frozen bits
def get_frozen_bits(K, N):
    ebn0 = 6

    # compute the sigma value
    esn0 = ebn0 + 10 * math.log10(K/N)
    sigma_vals = 1/(math.sqrt(2) * 10 ** (esn0 / 20))

    # create a frozen bit generator
    fbgen = tool_fb.Frozenbits_generator_GA_Arikan(K, N)
    # create a noise tool
    noise = tool_noise.Sigma(sigma_vals)
    # set the noise for which the frozen bits should be generated
    fbgen.set_noise(noise)
    # generate and store the forzen bits
    frozen_bits = fbgen.generate()

    return frozen_bits
