# FPGA
Le FPGA est utilisé pour faire l'encodage polaire. Pour ce faire il recoit en entrée UART une trame de bits à encoder. Il va ensuite encoder les bits et les renvoyer par UART. Pour l'instant, l'encodage parallèle n'a pas était testé sur carte, ni en combinaison avec l'UART.

---

## Encodage polaire
Celui-ci contient deux architecture pour faire le même encodage.

1. **Encodage série** : 

Supposons que l'on veuille encode un mot de taille N = 8 et de nombre de bits non gelés égale à K=6. On reçoit le code bit par bit par l'UART:
  - **Registre à décalage** : Un registre à décalage de 6 bits se rempli pour accueillir les 6 bits du mot de code.
  - **Comparateur** : Le comparateur permet d'introduire les bits gelés dans le mot de code. Pour cela il utilise un vecteur **Vector_Frozen** que l'utilisateur doit spécifier. Le vecteur est par exemple de cette forme : 
                                                                         
              **Vector_Frozen** :    [ 0 1 0 0 1 0 0 0 ]    |   Ici Les positions 3 et 6 sont gelées.
              **positions** :        [ 7 6 5 4 3 2 1 0 ]             |   En effet, les 1 indiquent qu'à cette position, il y a un bit gelé (donc 0).      
                                                                         

Pour réaliser cet encodage, on utilise cette structure 

2. **Encodage parallèle générique** :

---

## UART
