## ce code permet d'envoyer un tableau numpy de 1000 éléments vers un port USB puis les recois. 


import serial
import numpy as np
import time

start = time.time()

# Créer un tableau numpy de 10000 éléments aléatoires (0 ou 1)
img_array = np.random.randint(2, size=10000, dtype=np.uint8)

# Ouvrir le port série
ser = serial.Serial(port='/dev/ttyUSB1', baudrate=115200, timeout=1)

# Envoyer le tableau d'octets sur le port série
ser.write(img_array.tobytes())

# Attendre que toutes les données soient envoyées
ser.flush()

# Lire les données reçues
img_array_rec = ser.read(10000)

# Afficher les résultats
end = time.time()
print("temps d'exécution:", end - start)

	
