from typing import List
import sys
sys.path.insert(1, 'encoder')
sys.path.insert(1, 'UART')

# Import the python encoder
import encoder as software_encoder
# Import the vhdl encoder
import send_recv_FPGA as vhdl_encoder

# function that takes an array of char in parameter 

def compare_char_encoder(data_in: List[chr]):
    """Function that get the encoded char values from the python encoder and vhdl encoder and compare them
    for a given list of char

    Args:
        data_in (List[chr]): list of char to encode
    """
    # Create the encoder default encoder for char
    my_encoder = software_encoder.polar_encoder()

    N=16 # for a char, the encoded output is 16 bits
    encoded_bits = []

    for data in data_in:
        # My encoder
        encoded_bits.append(my_encoder.encode_char(chr(data)))
    print(len(encoded_bits))
        
    # vhdl encoder
    encoded_bits_vhdl = vhdl_encoder.send_rec_FPGA(data_in)

    # Compare lenght
    if(len(encoded_bits_vhdl) != len(encoded_bits)):
        print("error: length mismatch")
        print("vhdl length: " + len(encoded_bits_vhdl) + " | my encoder length: " + len(encoded_bits))
        return

    # compare the output of the two encoder
    for i in range(len(encoded_bits_vhdl)):
        if(encoded_bits_vhdl[i] != encoded_bits[i]):
            print("error")
            print("vhdl index: " + str(i) + " | bit value: " + str(encoded_bits_vhdl[i]))
            print("My encoder index : " + str(i) + " | bit value: " + str(encoded_bits[i]))
            break


if __name__ == "__main__":
    img_array = vhdl_encoder.read_image_grayscale("images/cat128x128.jpg")
    compare_char_encoder(img_array)
