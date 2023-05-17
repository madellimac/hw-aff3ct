# FPGA
Le FPGA est utilisé pour faire l'encodage polaire. Pour ce faire il recoit en entrée UART une trame de bits à encoder. Il va ensuite encoder les bits et les renvoyer par UART. Pour l'instant, l'encodage parallèle n'a pas était testé sur carte, ni en combinaison avec l'UART.

---

## Encodage polaire
Celui-ci contient deux architecture pour faire le même encodage.

1. **Encodage série Fp** : 

Supposons que l'on veuille encode un mot de taille N = 8 et de nombre de bits non gelés égale à K=6. On reçoit le code bit par bit par l'UART:
  - **Registre à décalage** : Un registre à décalage de 6 bits se rempli pour accueillir les 6 bits du mot de code.
  - **Comparateur** : Le comparateur permet d'introduire les bits gelés dans le mot de code. Pour cela il utilise un vecteur **Vector_Frozen** que l'utilisateur doit spécifier. Le vecteur est par exemple de cette forme : 
                                                                         
              **Vector_Frozen** :    [ 0 1 0 0 1 0 0 0 ]    |   Ici Les positions 3 et 6 sont gelées.
              **positions** :        [ 7 6 5 4 3 2 1 0 ]    |   En effet, les 1 indiquent qu'à cette position, il y a un bit gelé (donc 0).      
                                                                         
  - **Encodage** : L'encodage se réalise à l'aide d'une matrice Kernel de taille NxN = 8x8 ici : 

| 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 |  
|---|---|---|---|---|---|---|---|                                                        
| 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 |                                                        
| 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 |                                                        
| 1 | 1 | 1 | 1 | 0 | 0 | 0 | 0 |     = F8                                                  
| 1 | 0 | 1 | 0 | 1 | 0 | 0 | 0 |                                                       
| 1 | 1 | 1 | 1 | 1 | 1 | 0 | 0 |                                                       
| 1 | 0 | 1 | 0 | 1 | 0 | 1 | 0 |                                                       
| 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1 |                                                       
                                                       
                                                       
   -> En réalité, utiliser cette matrice revient réaliser cette opération 8 fois d'affilées :
                                  **registre <= registre xor (data_in & registre(N-1 downto 1))**
                                  
    On obtient à la fin notre code sur N=8 bits. 
    
2. **Encodage parallèle générique** :

-**Fonctionnement** : 
L'encodage parallèle consiste à diviser le mot de code que l'on veut coder pour les traiter séparemment dans des encodeurs série Fp puis
de faire passer les codes obtenus dans des accumulateurs rebouclés avec des xor pour obtenir notre mot de code sur 8 bits.

Reprenons notre exemple précédent avec cette fois-ci un encodage qui utilise 2 encodeurs F4 série. 
Donc N=8, P=4 et K=3 (nombre de bits non gelés dans chaque encodeur série)

![Encodage parallèle](/images/encodeur_para.PNG)

-**Exemple** :
Supposons que l'on veuille code, avec N = 8, P = 4 et K = 3, le mot :
[ 1 | 0 | 1 | 1 | 0 | 1 ] 



3. **Application**

Dans les faits, l'encodeur parallèle fonctionne aussi en mode série (N=P). Dans ce cas, l'accumulateur sera juste un réseau de bascule et le module
Fp sera celui décrit précédemment pour P=N. 
Cependant dans l'état actuel, il n'est capable que de générer un seul module Fp. Donc si l'on veut coder un vecteur de taille N = 8 pour P = 4,
il faut envoyer les 2 bouts de mot l'un après l'autre dans le module Fp. (Bien entendu, c'est une perte de temps).

Pour pouvoir générer 


---

## UART
