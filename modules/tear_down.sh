#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.


# prend en paramètre le chemin absolu vers le répertoire de test du paquetage
# le chemin se termine par "catégorie/nom_du_paquetage"
#

# copy the test image
# create and start vm
# install the package to be tested

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

