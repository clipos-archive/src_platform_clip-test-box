#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# Ce script prend en argument le script de test à effectuer (avec le chemin qui va bien)
# Il initialise l'environnement pour ce script, c'est à dire :
# - initialise les variables globales
# - charge les fonctions mises à disposition du script de test


BASENAME=$(basename -- "$0")

usage() {
    cat <<EOF
Usage:
${BASENAME} <test script to execute>
EOF
}

usage_exit() {
	usage
	exit 1
}


# ---------------------------------------------
if [[ "${#}" -ne 1 ]]; then
    usage_exit
fi


# ---------------------------------------------
TESTSCRIPT="$1"
TESTPATH=$(dirname $TESTSCRIPT)

# --------------------------------------------------
# initialise les variables globales et les fonctions
source test_functions.sh
init_global_var "$TESTPATH"
print_configuration > "$RESULT_PATH/$(basename $TESTSCRIPT).configuration"

# ------------------------------------
# exécute le script de test
# NB : cet appel est le dernier du script car les fonctions success/fail/error appelées par
# le script de test font un "exit"
source "$TESTSCRIPT"


