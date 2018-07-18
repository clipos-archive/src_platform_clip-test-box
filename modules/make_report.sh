#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

BASENAME="$(basename -- "$0")"

source test_functions.sh

usage() {
    cat <<EOF
Usage:
${BASENAME} <path to the root of the tests result tree> <path to the output report file>

NB : The <path to the root of the tests result tree> may not be the absolute tree root, that is the directory that contains the file test_base.conf. It can be any of the sub-directories of the absolute tree root, in that case the configuration will still take in account the content of the test_base.conf.
EOF
}

usage_exit() {
	usage
	exit 1
}

if [[ "${#}" -ne 2 ]]; then
    usage_exit
fi

# ----------------------------------
TEST_TREE_ROOT="$1"
REPORT_PATH="$2"

TEST_SUCCESS_RESULTS=$(grep "SUCCESS :" -r "$TEST_TREE_ROOT")
TEST_FAIL_RESULTS=$(grep "FAILED :" -r "$TEST_TREE_ROOT")
TEST_ERROR_RESULTS=$(grep "ERROR :" -r "$TEST_TREE_ROOT")

# ----------------------------------
# ecriture du rapport
# ----------------------------------
echo "TESTS REPORT" > $REPORT_PATH
echo  >> $REPORT_PATH
echo "Tests results tree root : $TEST_TREE_ROOT" >> $REPORT_PATH
echo  >> $REPORT_PATH


# ----------------------------------
# tests démarrés
NBSTARTED=$(grep "START :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.start" | wc -l)
echo "STARTED: $NBSTARTED"  >> $REPORT_PATH
echo >> $REPORT_PATH
grep "START :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.start" >> $REPORT_PATH
echo >> $REPORT_PATH

# ----------------------------------
# tests reussis
NBSUCCESS=$(grep "SUCCESS :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.result" | wc -l)
echo "SUCCESS: $NBSUCCESS"  >> $REPORT_PATH
echo >> $REPORT_PATH
grep "SUCCESS :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.result" >> $REPORT_PATH
sed -i "s/SUCCESS ://g" $REPORT_PATH
echo >> $REPORT_PATH

# ----------------------------------
# tests echoues
NBFAILED=$(grep "FAILED :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.result"|wc -l)
echo "FAILED: $NBFAILED"  >> $REPORT_PATH
echo >> $REPORT_PATH
grep "FAILED :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.result" >> $REPORT_PATH
sed -i "s/FAILED ://g" $REPORT_PATH
echo >> $REPORT_PATH

# ----------------------------------
# erreurs
NBERROR=$(grep "ERROR :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.result"|wc -l)
echo "ERROR: $NBERROR"  >> $REPORT_PATH
echo >> $REPORT_PATH
grep "ERROR :" -r "$TEST_TREE_ROOT" | grep "test\-[0-9]*\.sh\.result" >> $REPORT_PATH
sed -i "s/ERROR ://g" $REPORT_PATH

# ----------------------------------
# raccourcissement des chemins
sed -i "s,^$TEST_TREE_ROOT/,,g" $REPORT_PATH


