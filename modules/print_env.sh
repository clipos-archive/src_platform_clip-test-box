#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

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

# ---------------------------------------------
# initialise et affiche les variables globales
source test_main_config.sh "$1"
print_configuration
