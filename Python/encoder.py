import random
import numpy as np


# def generate_data_in():
#     """
#     Generate random value as input
#     """
#     for i in range(k):
#         #data_in.append(random.randint(0,1))
#         if(i < k/2):
#             data_in.append(1)
#         else:
#             data_in.append(0)

# def generate_frozen_bits():
#     """Generate random frozen bits as input.

#     Returns:
#         array: The frozen bits.
#     """
#     frozen_bits = []
#     for i in range(n):
#         if(i < k):
#             frozen_bits.append(0)
#         else:
#             frozen_bits.append(1)

#     return frozen_bits
    

def add_frozen_in_data(data_in, frozen_bits):
    """The frozen bits contains the position where zeros will be add to the data
    in.
    This function add the zeros at the right position in the data in

    Args:
        frozen_bits (array): The frozen bits

    Returns:
        array: the new data bits with the frozen bits added.
    """
    n = len(frozen_bits)
    out = [0]*n
    compteur = 0

    for i in range(n):
        if(frozen_bits[i] == 1):
            out[i] = 0
        else:
            out[i] = data_in[compteur]
            compteur = compteur + 1

    return out


def generate_kernel_matrix(N):
    """Create the kernel matrix for the polar encoder.

    Ex for N = 4.

    |1 0 0 0|\n
    |1 1 0 0|\n
    |1 0 1 0|\n
    |1 1 1 1|

    Args:
        N (int): The dimension of the matrix(2d). Must be a power of 2 (i.e. 2; 4; 8; 16...)

    Returns:
        numpy_array(2d): The kernel matrix
    """

    matrix = np.zeros((N,N), dtype=int)
    matrix[0,0] = 1

    """ 
    The first element of each row = 1.
    Each other element is calculated from this equation (starting from the second row):
    m(i,j) = m(i-1,j) XOR m(i-1,j-1) 
    """
    for i in range(1,N):
        if i != 0:
            matrix[i,0]=1
            
            for j in range(1,N):
                matrix[i,j] = matrix[i-1,j] ^ matrix[i-1,j-1]

    return matrix

def encode(data_in, frozen_bits):
    """
    The data is multiply with each row in the matrix.

    Ex: 
    data =   [0, 1]
    matrix = |1, 0|
             |1, 1|

    data_out = [(data(0) * matrix[0,0] + data(1)*matrix[0,1]), (data(0) * matrix[1,0] + data(1)*matrix[1,1]))
             = [0*1+1*0, 0*1+1*1] = [0, 1]
    

    Args:
        data_in (array): The data that we want to encode
        N: The size of the encoded data

    Returns:
        array: The data that is now encoded
    """

    dimension_bits = len(data_in)
    N = len(frozen_bits)

    if(dimension_bits >= N):
        return
    
    kernel_matrix = generate_kernel_matrix(N)
    data_to_encode = add_frozen_in_data(data_in, frozen_bits)
    #convert data to encode for bitwise operation
    data_to_encode = np.array(data_to_encode, dtype=int)
    # reverse data to encode
    data_to_encode = data_to_encode[::-1]

    encoded_bits = np.zeros(N, dtype=int)

    # multiply the data with the kernel matrix
    for i in range(0, N):
        for j in range(0, N):
            encoded_bits[i] += data_to_encode[j] & kernel_matrix[i, j]
        # the array is binary so we can do a modulo 2 to get the right value
        encoded_bits[i] = encoded_bits[i]%2

    # inverse the encoded bits
    encoded_bits = encoded_bits[::-1]

    return encoded_bits

if __name__ == '__main__':

    #verify that this works with the aff3ct    
    # k=4
    # n=8

    data_in = [1,1,0,0]
    frozen_bits = [1,1,1,0,1,0,0,0] # default value for k = 4 and N = 8

    encoded_bits = encode(data_in, frozen_bits)

    print(encoded_bits)
