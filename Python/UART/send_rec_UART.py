## ce code permet d'envoyer une image convertie en tableau numpy  vers un port USB puis la recevoir. 

import serial
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image
import time
import random
from numpy import asarray

somme_temps=0

img = Image.open("baboon.jpg").convert('L')

img_array = asarray(img)
img_1d = []
img_array_rec1=[]

img_2d = []
for i in range (len(img_array)):
    for j in range (len(img_array[0])):
        img_1d.append(img_array[i][j])

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
  

        start1 = time.time()
        if(len(img_1d)>10000):
            for k in range(10000):
                img_1d.remove(img_1d[0])
        else:
            for k in range(len(img_1d)):
                img_1d.remove(img_1d[0])
        end1 = time.time()
        somme_temps = somme_temps+(end1-start1)      ## pendant ce temps il ne y'a pas de transmission 

end = time.time()
    

nombre_d_erreur =0
for nbr in range (len(img_1d)):
    if( (img_array_rec1[nbr]==img_1d[nbr]) == False ) :
        nombre_d_erreur = nombre_d_erreur +1

# initialisation du tableau 2D reconstruit
img_array_reconstructed = [[0 for j in range(len(img_array[0]))] for i in range(len(img_array))]

# reconstruction du tableau 2D
for i in range(len(img_array)):
    for j in range(len(img_array[0])):
        img_array_reconstructed[i][j] = img_array_rec1[i*len(img_array) + j]

plt.imshow(img_array_reconstructed, cmap='gray')
plt.show()

print("temps d'execusion")
print(end-start-somme_temps)

print("taille de l'image 2d envoyée")
print(len(img_array),len(img_array[0]))

print("Nombre d'octets envoyés")
print(len(img_array_rec1))

print("Nombre d'erreurs de transmission")
print(nombre_d_erreur)

