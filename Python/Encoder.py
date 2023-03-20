import random
import numpy as np

k=4
n=8

data_in = []

def generate_data_in():
    for i in range(k):
        #data_in.append(random.randint(0,1))
        if(i < k/2):
            data_in.append(1)
        else:
            data_in.append(0)

def generate_frozen_bits():
    frozen_bits = []
    for i in range(n):
        if(i < k):
            frozen_bits.append(0)
        else:
            frozen_bits.append(1)

    return frozen_bits
    

# Add the frozen bits with the data
def add_frozen_in_data(frozen_bits):
    out = [0]*n
    compteur = 0

    for i in range(n):
        if(frozen_bits[i] == 1):
            out[i] = 0
        else:
            out[i] = data_in[compteur]
            compteur = compteur + 1

    return out

def encode(bits_to_encode):
    encoded_bits = 0

    # encoded_bits = encoded_bits xor (bits_to_encode & encoded_bits(n-& downto 1))
    for i in range(n):
        #print(bits_to_encode[i] << (n-1) + (encoded_bits >> 1))
        encoded_bits = encoded_bits ^ (bits_to_encode[i] << (n-1) + (encoded_bits >> 1))
        print(bin(encoded_bits))

    


if __name__ == '__main__':
    
    generate_data_in()

    frozen_bits = generate_frozen_bits()

    data_to_encode = add_frozen_in_data(frozen_bits)

    print(data_to_encode)

    encode(data_to_encode)