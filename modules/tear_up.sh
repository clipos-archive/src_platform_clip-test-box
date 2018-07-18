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

# récupération du répertoire de sortie des résultats
# --------------------------------------------------------------------
MAIN_RESULT="$RESULT_PATH"

if [ $? -ne 0 ]; then
    echo "${BASENAME} : erreur à l'initialisation"
    exit 1
fi

# création du répertoire de sortie
# --------------------------------------------------------------------
mkdir -p $MAIN_RESULT

# --------------------------------------------------------------------
# test si la vm est lancée

# $( $CLIP_VIRT_PATH/clip-virt list-vm ) | grep running | grep "$VM_NAME"

$CLIP_VIRT_PATH/clip-virt list-vm | grep running | grep "$VM_NAME"

if [ $? -ne 0 ]; then
    echo "la VM de test $VM_NAME n'est pas lancée. Les tests ne peuvent s'effectuer"
    ./tear_down.sh ${PATH_TO_TEST} > "$MAIN_RESULT/tear_down.output"
    exit 1
fi

# --------------------------------------------------------------------
# attend que le terminal serie soit prêt
./vm_console.py wait_for_os_launch "$VM_NAME" -t 120

if [ $? -ne 0 ]; then 
    echo "la VM est lancée mais la console série n'est pas prête : timeout"
    exit 1
fi

