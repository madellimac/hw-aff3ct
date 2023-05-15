# Encodage polaire matériel
## But
Ce projet a pour but de créer un environnement de test de l'encodage polaire matériel d'une image. L'image sera convertie en bit sur l'ordinateur. Un FPGA sera connecté à l'ordinateur via un port USB pour recevoir des bits à encoder et renvoyer les bits encodés par UART. L'ordinateur fera l'encodage de façon logicielle et comparera les résultats avec ceux du FPGA.



---
## Architecture du projet
Le projet est divisé en plusieurs partie. 
- ### FPGA:
  - **Encodage polaire** selon un nombre de bits donné en entrée [k] et un nombre total de bits encodé [N].
  - **Communication UART** avec l'ordinateur


- ### Python: 
  - **Encodage polaire** selon un nombre de bits donné en entrée [k] et un nombre total de bits encodé [N].
  - **Conversion d'image** en bits
  - **Communication UART** avec le FPGA
  - **Comparaison** des résultats de l'encodage polaire entre le logiciel aff3ct et le logiciel python

- ### Microcontrolleur:

---
## Installation
Pour installer le projet, il faut cloner le projet sur votre ordinateur. Il faut aussi installer les librairies suivantes:
- **Aff3ct (optionnel)** : https://aff3ct.github.io/installation.html
- **Matplotlib** : https://matplotlib.org/stable/users/installing.html
- **Numpy** : https://numpy.org/install/
- **Pyserial** : https://pyserial.readthedocs.io/en/latest/pyserial.html#installation
- **Pillow** : https://pillow.readthedocs.io/en/stable/installation.html

---
## Utilisation
### [FPGA](VHDL/README.md)


### [Python](Python/README.md) 


---
## Fonctionnement 
### Calculs d'encodage
Le vecteur de bit à encoder est de taille k. Les frozen bits sont ajoutés dans la série de bit à encoder pour former un ensemble de bit de taille N. Ce nouveau vecteur de bit est multiplier par une matrice de génération de taille N x N pour obtenir le vecteur de bit encodé. 
#### Frozen bits
Le vecteur de frozen bits est de taille N. Il est utilisé pour ajouter des 0 dans le vecteur de bits à encoder. Les 0 sont ajoutés à la position des frozen bits. La position des frozen bits est représenté par des 1 dans le vecteur de frozen bits
##### Exemple
- **Vecteur de bits à encoder** : [1 0]
- **Frozen bits** : [1 0 0 1]
- **Bits encodés** : [0 1 0 0]
  
  |Bits ini| - | ==1== | ==0== | - |
  |     ---|---|---|---|---|
  |Frozen  | 1 | 0 | 0 | 1 |
  |Encodés | 0 | 1 | 0 | 0 |
  
Des zéros sont ajoutés aux bits à encoder où il y a des 1 dans le vecteur de frozen bits, soit la position 1 et 4. 
#### Matrice de génération
- ### Encodage série
  Dans un encodage polaire série, les bits à encoder sont evoyés un à la suite de l'autre. L'encodeur utilise des registres à décallage suivi de XOR avec le bit suivant dans la trame. Le résultat est ensuite envoyé par UART. De plus, chaque bit est comparer avec un AND avec le frozen bit correspondant dans la matrice de génération.

  ![Encodage série](images/PolaireSerie.png)

  #### Matrice de génération
  La matrice de génération est une matrice de taille N x N. Elle est utilisée pour encoder les bits.  
- ### Encodage parallèle
---
## Aff3ct
Le logiciel aff3ct permet de faire l'encodage et le décodage sous différents protocoles. Il est disponible sur github. Une version C++ et python existe pour l'intégration rapide. Cependant, il est très lourd. Une version plus légère de l'encodage polaire en python a été créé dans ce projet et comparé avec le projet aff3ct pour s'assurer de la validité des résultats.