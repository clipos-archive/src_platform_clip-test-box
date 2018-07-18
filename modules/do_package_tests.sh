#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# paramètres :
# <option> <chemin des tests> 
# option : 
# all = effectue tous les tests
# single = effectue seulement les tests du répertoire T-xx terminant le chemin passé en argument
# base = effectue seulement les tests dans le répertoire du paquetage passé en argument

# actions :
# - appelle init_outputdir.sh
# - appelle tear_up.sh
# - appelle pour les tests de base : do_package_base_tests.sh
# - appelle pour les tests "single" : do_package_single_tests_group.sh pour chacun des groupes de test définis
# - appelle tear_down.sh

BASENAME="$(basename -- "$0")"

source test_functions.sh

usage() {
    cat <<EOF
Usage:
${BASENAME} <all/base/single> <path to the test directory>
EOF
}

usage_exit() {
	usage
	exit 1
}

if [[ "${#}" -ne 2 ]]; then
    usage_exit
fi

OPTION=$1
shift 1

# test  de la valeur d'option
# --------------------------------------------------------------------
if [ "$OPTION" != "all" ] && [ "$OPTION" != "single" ]  && [ "$OPTION" != "base" ]; then
    usage_exit
fi

# initialisation des variables globales
# --------------------------------------------------------------------
init_global_var "$1"
PATH_TO_TEST=$(readlink -f "$1")


# initialisation du repertoire de resultats
# ------------------------------------------
MAIN_RESULT="$RESULT_PATH"


# tear_up global pour l'ensemble des tests (base et groupes)
# --------------------------------------------------------------------
./tear_up.sh ${PATH_TO_TEST} > "$MAIN_RESULT/tear_up.output"
if [ $? -ne 0 ]; then
    echo "${BASENAME} : erreur au tear_up. Voir le fichier $MAIN_RESULT/tear_up.output"
    exit 1
fi

echo
echo "Test :  $PACKAGE_CATEGORY / $PACKAGE_NAME"
echo "${PATH_TO_TEST}"
echo "Option des tests : $OPTION"
echo

# exécution des tests de base = seuls ceux du répertoire du paquetage
# --------------------------------------------------------------------
if [ $OPTION == "all" ] || [ $OPTION == "base" ]; then 
    # exécution des tests de base
    echo "Execute tests de base :"
    ./do_package_base_tests.sh "${PATH_TO_TEST}"
    echo
fi

# exécution des tests "single" = ceux présents dans les sous répertoires T-xx du répertoire du paquetage
# --------------------------------------------------------------------
if [ $OPTION == "all" -o $OPTION == "single" ]; then 
    # exécution des groupes de tests
    echo "Execute groupes de tests :"
    
    if [[ "${PATH_TO_TEST}" == */T-* ]]; then
        GROUPES_DE_TEST="${PATH_TO_TEST}"
    else        
        # test si il y a bien des sous-repertoires T-*        
        find "${PATH_TO_TEST}" -type d -print | grep -q "/T-[0-9]*"
        if [ $? -ne 0 ]; then
            GROUPES_DE_TEST=""
        else
            GROUPES_DE_TEST=$(ls -d "${PATH_TO_TEST}"/T-* )
        fi
    fi
    
    for groupe in $GROUPES_DE_TEST; do
        groupenb=$(echo $groupe|grep -o "T\-[0-9]*")
        echo "groupe $groupenb"
        ./do_package_single_test_group.sh $groupe
    done
    echo
fi


# tear_down global pour l'ensemble des tests (base et groupes)
# --------------------------------------------------------------------
./tear_down.sh ${PATH_TO_TEST} > "$MAIN_RESULT/tear_down.output"
if [ $? -ne 0 ]; then
    echo "${BASENAME} : erreur au tear_down. Voir le fichier $MAIN_RESULT/tear_down.output"
    exit 1
fi


