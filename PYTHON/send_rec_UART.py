import serial
import numpy as np
from PIL import Image
import time

start = time.time()

img = Image.open("baboon.jpg").convert('L') # L pour noir et blanc
img_array = np.asarray(img)
img_1d = img_array.flatten()
img_2d = [[] for _ in range(len(img_array))] # Initialisation de img_2d avec des sous-listes vides

block_size = 10000
ser = serial.Serial(port='/dev/ttyUSB1', baudrate=230400, timeout=0.05)

nombre_d_erreur = 0

for i in range(0, len(img_1d), block_size):
    block = img_1d[i:i+block_size]
    ser.write(block.tobytes())
    ser.flush()

    # Réception des données
    img_array_rec = b''
    while len(img_array_rec) < block_size:
        data = ser.read(block_size - len(img_array_rec))
        if not data:
            # Si aucune donnée n'a été reçue, sortir de la boucle
            break
        img_array_rec += data

    if len(img_array_rec) != block_size:
        # Si la taille des données reçues n'est pas la même que la taille du bloc envoyé, sortir de la boucle
        break

    img_array_rec1 = np.frombuffer(img_array_rec, dtype=np.uint8)


end = time.time()

# Reconstruction de l'image à partir de img_1d
for li in range(len(img_array)):
    for col in range(len(img_array[0])):
        img_2d[li].append(img_1d[li*len(img_array[0]) + col])

img_array_2d = np.array(img_2d, dtype=np.uint8)
img_rec = Image.fromarray(img_array_2d, mode='L')
img_rec.show()
debit = len(img_1d)/(end-start)
print(len(img_1d))
print(len(img_array)*len(img_array[0]))
print("temps d'exécution : {:.2f} secondes".format(end-start))



