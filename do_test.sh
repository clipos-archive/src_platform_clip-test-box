#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# effectue soit :
# - les tests de base
# - le groupe de test donné
# - tous les tests

# pour chaque option :
# - fait le tear-up global
# - effectue l'action demandée
# - fait le tear-down global


BASENAME="$(basename -- "$0")"
DIRNAME="$(dirname "$0")"
MODULES_PATH=$DIRNAME"/modules"
PWD=($pwd)

usage() {
cat <<EOF
Usage:

${BASENAME} all <path to the package directory in the tree of tests>
${BASENAME} single <path to the sub-directory of the package directory in the tree of tests that ends with T-xx>
${BASENAME} base <path to the package directory in the tree of tests>
${BASENAME} start_vm <path to the configuration file>
${BASENAME} stop_vm <path to the configuration file>
${BASENAME} test_all_packages <all|single|base> <path to the root of the tests tree>
${BASENAME} make_report <path to the root of the tests result tree> <output file pathname>
${BASENAME} print_env <path to test directory>

examples :
ex. : ${BASENAME} all sample/test_root_directory/test_de_demarrage/portage-overlay/dev-vcs/git
ex. : ${BASENAME} single sample/test_root_directory/test_de_demarrage/portage-overlay/dev-vcs/git/T-01
ex. : ${BASENAME} base sample/test_root_directory/test_de_demarrage/portage-overlay/dev-vcs/git

NB for : 
${BASENAME} test_all_packages <all|single|base> <path to the root of the tests tree> :
The <path to the root of the tests tree> may not be the absolute tree root, that is the directory that contains the file test_base.conf. It can be any of the sub-directories of the absolute tree root, in that case the configuration will still take in account the content of the test_base.conf.

NB for :
${BASENAME} make_report <path to the root of the tests result tree> <output file pathname> :
The <path to the root of the tests tree> may not be the absolute tree root of the results tree, that is the directory that corresponds to the one that contains the file test_base.conf. It can be any of the sub-directories of the absolute result tree root.

NB for : 
${BASENAME} print_env <path to test directory> :
print the values of global variables available to the test scripts in the given test directory. This directory can be a leaf of the tests tree or not. In the latter case the values shown are the ones initialized by configuration files from the root of the test tree to the given directory.

EOF
}

usage_exit() {
	usage
	exit 1
}

all() {
    cd $MODULES_PATH
    ./do_package_tests.sh all "${1}"
    cd $PWD
}

single() {
    cd $MODULES_PATH
    ./do_package_tests.sh single "${1}"
    cd $PWD    
}

base() {
    cd $MODULES_PATH
    ./do_package_tests.sh base "${1}"
    cd $PWD
}

start_vm() {
    cd $MODULES_PATH
    ./start_vm.sh "${1}"
    cd $PWD    
}

stop_vm() {
    cd $MODULES_PATH
    ./stop_vm.sh "${1}"
    cd $PWD    
}

test_all_packages() {
    local OPTION="${1}"
    local PATH_TO_TEST_TREE_ROOT="${2}"
    cd $MODULES_PATH
    ./do_test_all_packages.sh "$OPTION" "$PATH_TO_TEST_TREE_ROOT"
    cd $PWD
}

make_report() {
    if [ ! -e "$2" ]; then
        touch "$2"
        if [ $? -ne 0 ]; then
            echo "can not create $2"
            exit 1
        fi
    fi
    
    local TEST_TREE_ROOT=$(realpath "$1")
    local REPORT_PATH=$(realpath "$2")
    
    cd $MODULES_PATH
    ./make_report.sh $TEST_TREE_ROOT $REPORT_PATH
    cd $PWD    
}

print_env() {
    cd $MODULES_PATH
    ./print_env.sh "${1}"
    cd $PWD
}


## We do not need to run as root
if [[ ${EUID} -eq 0 ]]; then
    echo "Do NOT run me as root"
    echo "If any libvirt steps are failling, check the libvirtd configuration:"
    printf "%s config\n" "${BASENAME}"
    exit 1
fi

if [[ "${#}" -lt 1 ]]; then
    usage_exit
fi

case "${1}" in
    "--help"|"-h")
        usage
        exit 0
        ;;
    "all")
        if [[ "${#}" -ne 2 ]]; then
            usage_exit
        fi
        shift 1
        all $(realpath "${@}")
        ;;
    "single")
        if [[ "${#}" -ne 2 ]]; then
            usage_exit
        fi
        shift 1
        single $(realpath "${@}")
        ;;
    "base")
        if [[ "${#}" -ne 2 ]]; then
            usage_exit
        fi
        shift 1        
        base $(realpath "${@}")
        ;;
    "start_vm")
        if [[ "${#}" -ne 2 ]]; then
            usage_exit
        fi
        shift 1
        start_vm $(realpath "${@}")
        ;;
    "stop_vm")
        if [[ "${#}" -ne 2 ]]; then
            usage_exit
        fi
        shift 1
        stop_vm $(realpath "${@}")
        ;;
    "test_all_packages")
        if [[ "${#}" -ne 3 ]]; then
            usage_exit
        fi
        shift 1
        test_all_packages "$1" $(realpath "$2")
        ;;
    "make_report")
        if [[ "${#}" -ne 3 ]]; then
            usage_exit
        fi
        shift 1        
        make_report "$1" "$2"
        ;;        
    "print_env")
        if [[ "${#}" -ne 2 ]]; then
            usage_exit
        fi
        shift 1        
        print_env $(realpath "${@}")
        ;;            
    *)
        echo "No command or wrong command specified."
        usage_exit
esac
