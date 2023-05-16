## ce code permet d'envoyer une image convertie en tableau numpy  vers un port USB puis la recevoir. 

import serial
import numpy as np
#import matplotlib.pyplot as plt
from PIL import Image
import time
import random
from numpy import asarray

somme_temps=0

def read_image_grayscale(image_file):
    """Read a grayscale image and return a 1D array of pixels (8 bit).

    Args:
        image_file (string): the path of the image file

    Returns:
        [char]: array of the image pixels (length = width * height)
    """
    img = Image.open(image_file).convert('L')

    img_array = asarray(img)
    img_1d = []
    for i in range (len(img_array)):
        for j in range (len(img_array[0])):
            img_1d.append(img_array[i][j])
    return img_1d

def send_rec_FPGA(img_1d):
    img_array_rec1=[]

    img_2d = []
    l = int(len(img_1d)/10000)+1 
    start = time.time()
    ser = serial.Serial(port='/dev/ttyUSB1', baudrate=115200, timeout=0.05 )
    for inc in range (l):
        
            # Envoyer l'octet correspondant à la valeur du pixel
            ser.write(img_1d[0:10000])
            ser.flush()
            img_array_rec = ser.readline()


            while ser.inWaiting():
                img_array_rec = img_array_rec+ser.readline()
            
            for i in range(len(img_array_rec)):
                img_array_rec1.append(int(img_array_rec[i]))
    

            # start1 = time.time()
            if(len(img_1d)>10000):
                for k in range(10000):
                    img_1d.remove(img_1d[0])
            else:
                for k in range(len(img_1d)):
                    img_1d.remove(img_1d[0])
            # end1 = time.time()
            # somme_temps = somme_temps+(end1-start1)      ## pendant ce temps il ne y'a pas de transmission 
            
    return img_array_rec1
