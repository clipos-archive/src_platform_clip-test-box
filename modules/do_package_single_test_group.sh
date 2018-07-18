#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# prend en paramètre le chemin absolu vers le répertoire de test du paquetage
# le chemin se termine par "catégorie/nom_du_paquetage/T-X"
# actions :
# - appelle local-tear-up
# - exécute chacun des fichiers de test présent dans le répertoire T-X qui sont nommés TT-Y avec Y le numéro du test
# - appelle local-tear-down

BASENAME="$(basename -- "$0")"

source test_functions.sh

usage() {
    cat <<EOF
Usage:
${BASENAME} <path to the test directory>
EOF
}

usage_exit() {
	usage
	exit 1
}

if [[ "${#}" -ne 1 ]]; then
    usage_exit
fi

# initialisation des variables globales
# --------------------------------------------------------------------
init_global_var "$1"
PATH_TO_TEST=$(readlink -f "$1")


# vérification que le chemin pointe bien vers un groupe de tests
# vérification que le chemin passé en argument pointe vers un groupe de test ("T-x").
# -------------------------------------------
if [ -z "${TEST_GROUP}" ]; then
    echo "${PATH_TO_TEST} n'est pas le chemin d'un groupe de test, il doit se terminer par T-xx"
    exit 1
fi

# initialisation du repertoire de resultats
# ------------------------------------------
mkdir -p $RESULT_PATH

# récupération des fichiers de test à exécuter
# -------------------------------------------
TESTS_LIST=$( ls "${PATH_TO_TEST}"/test-* 2> /dev/null)

if [ "$TESTS_LIST" == "" ]; then
    exit 0
fi

# local tear up
# -------------------------------------------
if [ -f "${PATH_TO_TEST}/local_tear_up.sh" ]; then 
    source ${PATH_TO_TEST}/local_tear_up.sh > "$RESULT_PATH/local_tear_up.output"
    if [ $? -ne 0 ]; then
        echo "${BASENAME} : erreur à l'initilisation : local_tear_up.sh. Voir le fichier $RESULT_PATH/local_tear_up.output"
        exit 1
    fi
fi

# effectue les tests
# -------------------------------------------
for i in ${TESTS_LIST}; do
    OUTPUT_FILE=$(basename ${i})".output"
    echo "execute "$(basename ${i})
    ./test_wrapper.sh ${i} > "$RESULT_PATH/$OUTPUT_FILE"
done

# local tear down
# -------------------------------------------
if [ -f "${PATH_TO_TEST}/local_tear_down.sh" ]; then 
    source ${PATH_TO_TEST}/local_tear_down.sh > "$RESULT_PATH/local_tear_down.output"
    if [ $? -ne 0 ]; then
        echo "${BASENAME} : erreur au nettoyage : local_tear_down.sh. Voir le fichier $RESULT_PATH/local_tear_down.output"
        exit 1
    fi    
fi
