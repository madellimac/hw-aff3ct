import random
import numpy as np


class polar_encoder:
    def __init__(self, frozen_bits = [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0]):
        """An encoder that use the polar code to encode the data.

        Args:
            frozen_bits (list, optional): _description_. Defaults to [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0] 
            for a char. The length of the frozen bits must be a power of 2 (i.e. 2; 4; 8; 16...) and represent the 
            number of encoded bits. The length of data that will be encoded need to represent the number of 0 in the 
            frozen bits list.
        """
        self.frozen_bits = frozen_bits
        self.kernel_matrix = self.__generate_kernel_matrix(len(self.frozen_bits))

    def __add_frozen_in_data(self, data_in, frozen_bits):
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


    def __generate_kernel_matrix(self, N):
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

    
    def __generate_frozen_bits(self, k, N):
        """Generate the frozen bits for the polar encoder from the reliable channels in the text file.
        1024 frozen bits are generated.

        Args:
            k (_type_): number of information bits
            N (_type_): number of encoded bits
        """
        reliable_channel_file = "text_files/reliable_channel_1024.txt"

        # read the file that contains the reliable channels
        file = open(reliable_channel_file, "r")
        header1 = file.readline()
        header2 = file.readline()
        channels = file.readline()

        # convert the string to an array
        channel_arr = channels.split(" ")

        # remove the last element of the array (it's a \n)
        channel_arr.pop()

        # convert the string to int
        channel_arr = [int(i) for i in channel_arr]

        # Put zero in the frozen bits array for the first k reliable channels
        # also don't consider channel > N
        frozen_bits = [1]*N
        index_k = 0
        for i in range(len(channel_arr)):
            if channel_arr[i] < N:
                frozen_bits[channel_arr[i]] = 0
                index_k += 1
                if index_k == k:
                    break

        return frozen_bits


    def encode(self, data_in):
        """
        Encode the data with the polar encoder.
        The data is multiply with each row in the matrix.

        Args:
            data_in (int[]): The data that we want to encode
            frozen_bits (int[]): The frozen bits. Defaults to [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0] for k = 8 and N = 16

        Returns:
            array: The data that is now encoded

        Ex: 
        data =   [0, 1]
        matrix = |1, 0|
                |1, 1|

        data_out = [(data(0) * matrix[0,0] + data(1)*matrix[0,1]), (data(0) * matrix[1,0] + data(1)*matrix[1,1]))
                = [0*1+1*0, 0*1+1*1] = [0, 1]
        """

        dimension_bits = len(data_in)
        N = len(self.frozen_bits)

        if(dimension_bits >= N):
            print("error: the data to encode is larger than N")
            return
        
        data_to_encode = self.__add_frozen_in_data(data_in, self.frozen_bits)

        #convert data to encode for bitwise operation
        data_to_encode = np.array(data_to_encode, dtype=int)
        
        # reverse data to encode
        data_to_encode = data_to_encode[::-1]

        encoded_bits = np.zeros(N, dtype=int)

        # multiply the data with the kernel matrix
        for i in range(0, N):
            for j in range(0, N):
                encoded_bits[i] += data_to_encode[j] & self.kernel_matrix[i, j]
            # the array is binary so we can do a modulo 2 to get the right value
            encoded_bits[i] = encoded_bits[i]%2

        # inverse the encoded bits
        encoded_bits = encoded_bits[::-1]

        return encoded_bits

    def encode_char(self, data_in):
        """Function that encode the data from a char to a binary array

        Args:
            data_in (_type_): char that we want to encode

        Returns:
            encoded_bits (array of bits[int]): the encoded data
        """
        # convert the char to binary array of 8 bits
        data_in = [int(x) for x in list('{0:08b}'.format(ord(data_in)))]
        
        # encode the data
        encoded_bits = self.encode(data_in)

        return encoded_bits

if __name__ == '__main__':
    # test
    # k=4
    # n=8

    # data_in = [1,1,0,0]
    # frozen_bits = [1,1,1,0,1,0,0,0] # default value for k = 4 and N = 8

    # encoded_bits = encode(data_in, frozen_bits)

    # print(encoded_bits)
    my_encoder = polar_encoder()
    frozen_bits = my_encoder.__generate_frozen_bits(1, 128)
    print(frozen_bits)
