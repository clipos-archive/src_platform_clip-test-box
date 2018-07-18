#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

BASENAME="$(basename -- "$0")"

source test_functions.sh

# ---------------------------
usage() {
    cat <<EOF
Usage:
${BASENAME} <option all|single|base> <path to the test directory root>
EOF
}

usage_exit() {
	usage
	exit 1
}

if [[ "${#}" -ne 2 ]]; then
    usage_exit
fi

# ---------------------------
OPTION="$1"
PATH_TO_TEST_TREE_ROOT="$2"

# ---------------------------
# liste tous les répertoires qui contiennent un script de test
TEST_DIRECTORIES=$(find "$PATH_TO_TEST_TREE_ROOT" -iname test-*.sh -exec dirname {} \;)

for test_directory in $TEST_DIRECTORIES; do
    # ne lance pas le test pour les répertoires qui se terminent par T-[0-9*]
    echo $test_directory | grep -q "/T-[0-9]*"
    if [ $? -ne 0 ]; then        
        ./do_package_tests.sh $OPTION "$test_directory"
    fi
done