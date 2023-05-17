# Encodage Polaire Python
## Utilisation
La section python est exécuté directement sur l'ordinateur. [L'encodeur](encoder/encoder.py) peut être utilisé de deux façons différentes.
  1. **Encodage d'un char** : Permet d'encoder un char (8 bit) avec les frozen bits définis dans le code.
  2. **Encodage d'une longueur variable** : Un tableau de bit est donné en entrée et l'encodeur polaire va encoder les bits selon les frozen bits envoyés en paramètre.

La classe **encoder.py** permet de faire l'encodage. Elle est dans le répertoire `/Python/encoder/encoder.py`. Pour l'utiliser, il faut importer la classe dans votre code python. Ensuite, il faut créer un objet de la classe encoder `enc = encoder.polar_encoder(forzen_bits)`. Les frozen_bits sont un tableau de bits *(int)* où les 1 représentent les bits gelées et les 0 les bits des données.

Il faut ensuite appeler la fonction `encode(data_in)` avec les données à encoder sous forme de tableau de bit *(int)*. **À noté que la longueur du tableau de donnée doit être égal au nombre de zéros dans le tableau de frozen_bits**. La fonction `encode()` retourne un tableau de bits encodés. Sa longueur est la même que la longueur du tableau de *frozen_bits*. 

### Exemple
``` Python
import encoder
# k = 8, N=16
frozen_bits = [1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0]
enc = encoder.polar_encoder(frozen_bits)
data_in = [1, 0, 1, 0, 1, 0, 1, 0] # 8 bits = k
data_out = enc.encode(data_in) # 16 bits = N
```

### Comparaison avec le FPGA
Un script [compare_encoder.py](compare_encoder.py) permet de lire une image. L'image est transformé en list de char (8 bits). Ensuite, le script parcours cette liste pour faire un encodage polaire avec l'encoder python de ce projet. Après, il envoit les données par UART au FPGA qui encode les données à son tour.

Cependant, il y avait des problèmes dans la communication UART, donc cette fonctionnalité n'a pas pu être testé....


### Tests
#### Requis
- **py_aff3ct** est nécessaire pour faire fonctionner ces tests.
- **Chemin de aff3ct** : Il faut modifier le chemin dans la variable `aff3ct_path` dans les fichiers de test du répertoire `Python/encoder/tests`. Le chemin doit être celui du répertoire py_aff3ct sur votre ordinateur.
#### [Frozen bits generator](encoder/tests/frozen_bits_generator.py)

Ce script permet de définir le tableau de frozen bits à utiliser selon k et N. Pour définir ce faire, la librairie aff3ct est utilisée. 

Pour l'utiliser, il faut lancer le script dans la console avec les arguments k et N. Le script va ensuite afficher le tableau de frozen bits à utiliser. Il faut copier ce tableau dans le code python.

Exemple pour k=4 et N=8
``` bash
$ python3 frozen_bits_generator.py 4 8
[1, 1, 1, 0, 1, 0, 0, 0]
```

#### [Encoder test](encoder/tests/test_encoder.py)
Ce script a été utilisé pour s'assurer de la validité des résultats de l'encodeur polaire. Il encode un tableau de bit avec les frozen bits définis dans le code. Il compare ensuite les résultats avec ceux de la librairie aff3ct. 

Si il n'y a aucune erreur, le programme s'exécute sans rien afficher. Sinon, il affiche l'erreur et quitte.

Ce script contient aussi une fonction ```encode_char_to_file()``` qui permet de calculer l'encodage pour les 256 char et les enregistrer dans un fichier texte.
