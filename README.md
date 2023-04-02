# Guide d'utilisation du code python :

Ce code Python a pour objectif de transférer une image via une connexion série, tout en vérifiant si des erreurs de transmission se produisent. Le processus commence par l'importation de bibliothèques nécessaires pour la communication série (**Pyserial**), la manipulation de tableaux (**Numpy**), la gestion d'images et la mesure du temps (**PIL**). L'image est chargée puis convertie en un tableau numpy, puis aplatie en une liste unidimensionnelle. Une liste vide est créée pour stocker les données à partir de la liste unidimensionnelle pour la reconstruction de l'image plus tard.  

Le code envoie les données par blocs à l'aide de la méthode `write()` d'un objet de connexion série. Les blocs sont lus depuis la connexion série et stockés dans une variable. Si la taille des données reçues est différente de la taille du bloc envoyé, une erreur est signalée et la boucle est arrêtée. Le nombre d'erreurs de transmission est calculé à l'aide de la fonction `count_nonzero()` de numpy.  

Une fois la transmission terminée, le temps d'exécution est enregistré et affiché, ainsi que la taille de la liste unidimensionnelle et la taille de l'image en pixels. L'image est ensuite reconstruite à partir de la liste unidimensionnelle, remplissant la liste vide précédemment créée. La liste est convertie en tableau numpy et en une image PIL avant d'être affichée.  

