# Encodage polaire matériel
## But
Ce projet a pour but de créer un environnement de test de l'encodage polaire matériel d'une image. L'image sera convertie en bit sur l'ordinateur. Un FPGA sera connecté à l'ordinateur via un port USB pour recevoir des bits à encoder et renvoyer les bits encodés par UART. L'ordinateur fera l'encodage de façon logicielle et comparera les résultats avec ceux du FPGA.

## Aff3ct
Le logiciel aff3ct est disponible sur github. Une version C++ et python existe pour l'intégration rapide. Il permet de faire l'encodage et le décodage sous différents protocoles. Cependant, il est très lourd. Une version plus légère de l'encodage polaire en python a été créé dans ce projet et comparé avec le projet aff3ct pour s'assurer de la validité des résultats.

---
## Architecture du projet
Le projet est divisé en plusieurs partie. 
- ### FPGA:
  - **Encodage polaire** selon un nombre de bits donné en entrée [k] et un nombre total de bits encodé [N].
  - **Communication UART** avec l'ordinateur


- ### Python: 
  - **Encodage polaire** selon un nombre de bits donné en entrée [k] et un nombre total de bits encodé [N].
  - **Conversion d'image** en bits
  - **Comparaison** des résultats de l'encodage polaire entre le logiciel aff3ct et le logiciel python
  - **Communication UART** avec le FPGA

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
### FPGA
Celui-ci contient deux architecture pour faire le même encodage.
1. **Encodage série** : 
2. **Encodage parallèle** :

### Python
La section python est exécuté directement sur l'ordinateur. L'encodeur peut être utilisé de deux façons différentes.
  1. **Encodage d'un char** : Permet d'encoder un char (8 bit) avec les frozen bits définis dans le code.
  2. **Encodage d'une longueur variable** : Un tableau de bit est donné en entrée et l'encodeur polaire va encoder les bits selon les frozen bits envoyés en paramètre.

#### Frozen bits
Pour définir les frozen bits à utiliser, la librairie aff3ct est utilisée. Un code python dans le répertoire `/Python/encoder/tests/forzen_bits_generator.py`


## Fonctionnement 
- ### Encodage série
