Utilisation :
-------------

do_test start_vm chemin_vers_fichier_de_configuration : fait une copie temporaire du disque (définit dans le fichier de configuration) et lance la vm de test
do_test stop_vm chemin_vers_fichier_de_configuration : arrête la vm de test et supprime la copie temporaire du disque (définit dans le fichier de configuration)

do_test all/base/single chemin_vers_le_repertoire_de_test_d_un_paquetage : effectue :
- all : tous les tests du répertoire du paquetage et des sous répertoires 
- base : uniquement les tests du répertoire du paquetage
- single : uniquement les tests d'un sous-répertoire se terminant par T-xx : la différence avec base est que chaque sous-répertoire T-xx peut avoir tear_up et tear_down local

Important : définition du répertoire racine des tests :
-------------------------------------------------------
Est considéré comme répertoire racine des l'arborescence de test, le répertoire qui contient le fichier test_base.conf.


Notes sur les scripts de test :
-------------------------------
NB : chaque script de test doit se nommer "test-x.sh" ou x est un numéro

Les tests sont organisés dans une arborescence qui peut compter autant de niveaux que souhaité du moment que :
- les deux derniers (vers les feuilles) soient la catégorie du paquetage (media-libs), puis le nom du paquetage (vlc)
ou bien les trois derniers 
- les trois derniers (vers les feuilles) soient la catégorie du paquetage (media-libs),puis le nom du paquetage (vlc), puis un répertoire nommé T-x ou x est un numéro

Les scripts de test s'appuient sur une configuration qui est répartie le long de l'arborescence des fichiers de test. Le répertoire racine de l'arbre de test contient le fichier test_base.conf, ses sous-répertoires peuvent contenir chacun un fichier test.conf. Ces fichiers sont sourcés successivement en partant du répertoire racine, ainsi les fichiers de configuration des sous-répertoires peuvent adapter la configuration globale de plus en plus finement.

Les scripts de test peuvent être ainsi répartis en deux groupes :
- les tests de base qui sont stockés dans le répertoire qui se termine par catégorie/nom_paquetage
- les groupes de tests qui chacun rassemble des tests dans un répertoire qui se termine par catégorie/nom_paquetage/T-x ou x est le numéro du groupe, ce répertoire T-x peut contenir des scripts "local_tear_up" "local_tear_down"

le nom des fichiers de test est "test-x" avec x le numéro du test : qu'il s'agisse de tests de base ou de tests appartenant à un groupe de test.

Du point de vue du cycle de vie des tests, quand tous les tests sont appelés par "do_package_all_tests.sh", les actions suivantes sont effectuées :
- appel de tear_up.sh
- appel des fichiers de test de base test-x
- pour chaque groupe T-x : 
    - appel du fichier local_tear_up.sh
    - appel de chacun des fichiers test-x
    - appel du fichier local_tear_down.sh
- appel de tear_down.sh

Les sorties des tests ainsi que celles des appels aux fichiers tear* sont stockées dans une arborescence identiques à celle les contenant mais placée dans le répertoire OUTPUT_DIR défini dans les fichiers de configuration.


Chaque script de test reçoit en argument le répertoire final contenant le test à exécuter, c'est à dire se terminant par la catégorie / le nom du paquetage / éventuellement le groupe de test. Il remonte jusqu'au répertoire contenant test_base.conf, et source les fichiers de configuration en partant de test_base.conf jusqu'au répertoire du paquetage.

Les variables définies dans le fichier de configuration de base sont :
-----------------------------------------------------------------------
# image de base
BASE_IMAGE="/home/data1/Clip/clip-kvm/clip-vm-stable_4.4.2-cc34-ca13-rc1-ra31_base.qcow2"

# image différentielle instrumentée : durée de vie plusieurs tests
BASE_INSTRUMENTED_IMAGE="/home/data1/Clip/clip-kvm/test.qcow2"

# le nom de l'image de travail : durée de vie le test = du tear_up au tear_down (ce n'est pas très propre mais un script local_tear_down pourrait appeler tear_down puis tear_up pour relancer une nouvelle vm)
BASE_WORK_IMAGE_NAME="/home/data1/Clip/clip-kvm/work_test.qcow2"

# nom de la vm créée et utilisée pour les tests : durée de vie le test
VM_NAME="tmp_vm"

# emplacement de clip-virt
CLIP-VIRT_PATH=""

# le répertoire de travail qui va contenir l'image de travail
WORK_DIR="/home/data1/Clip/tmp/test_work_dir/"

# le répertoire de sortie
OUTPUT_DIR="/home/data1/Clip/tmp/test_output_dir/"

# le nom de la vm
VM_NAME="tmp_vm"

Ecriture des scripts de test :
-------------------------------
chaque script de test est lancé par un wrapper qui initialise pour lui :
- les variables globales : aux variables vues ci-dessus peuvent s'ajouter les bariables 
- les fonctions du fichier modules/test_functions.sh que le script peut appeler

Le script de test peut ainsi commencer par appeler "test_start_message" pour écrire le message de démarrage de test, puis se terminer par un appel à "success" "fail" "error".

Rapport global des tests :
--------------------------
La compilation des résultats de test s'appuie sur les messages écrits par les fonctions "success" "fail" "error".




