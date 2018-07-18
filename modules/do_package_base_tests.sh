#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# effectue les tests placés dans le répertoire du paquetage en dehors d'un groupe T-X
# prend en argument le chemin vers le répertoire du paquetage qui se termine par "categorie/paquetage"
# appelle successivement les scripts "test-X" ou X est un numéro

BASENAME=$(basename -- "$0")
DIRNAME=$(dirname "$0")

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

# vérification que le chemin passé en argument pointe bien vers le répertoire racine du paquetage et non pas vers 
# un groupe de test ("T-x").
# --------------------------------------------------------------------
if [ -n "${TEST_GROUP}" ]; then
    echo "${PATH_TO_TEST} est le chemin d'un groupe de test et non pas du répertoire du paquetage"
    exit 1
fi

# initialisation du repertoire de resultats
# ------------------------------------------
mkdir -p $RESULT_PATH

# récupération des fichiers de test à exécuter
# --------------------------------------------------------------------
TESTS_LIST=$( ls "${PATH_TO_TEST}"/test-* 2> /dev/null)

# effectue les tests
# --------------------------------------------------------------------
for i in ${TESTS_LIST}; do
    OUTPUT_FILE=$(basename ${i})".output"
    echo "execute "$(basename $i)
    ./test_wrapper.sh ${i}  > "$RESULT_PATH/$OUTPUT_FILE"
done
