#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.
declare -a conffiles_paths
PACKAGE_NAME=""
PACKAGE_CATEGORY=""
ROOT_TEST_DIRECTORY=""
TEST_GROUP=""
nb_conf_files=0

# prend en paramètre le chemin absolu vers le répertoire de test du paquetage
# le chemin se termine par "catégorie/nom_du_paquetage/T-X" ou "catégorie/nom_du_paquetage"
# ou X est le numéro du répertoire de test

# --------------------------------------------------------
# traite le chemin vers le répertoire de test du paquetage
# et initialise les variables :
# package_name = le nom du paquetage (le dernier élément du chemin du paquetage)
# package_category = le nom de la catégorie (l'avant dernier élément du chemin du paquetage)
# les fichiers de configuration successifs en partant de celui de la racine qui doit se nommer
# test_base.conf tandis que les éventuels suivants doivent se nommer test.conf
#


print_configuration() {
    echo
    echo "Configuration"
    echo "-------------------"
    echo "PACKAGE_NAME = ${PACKAGE_NAME}"
    echo "PACKAGE_CATEGORY = ${PACKAGE_CATEGORY}"
    echo "TEST_GROUP = ${TEST_GROUP}"
    echo "ROOT_TEST_DIRECTORY = ${ROOT_TEST_DIRECTORY}"
    echo "BASE IMAGE = ${BASE_IMAGE}"
    echo "BASE_INSTRUMENTED_IMAGE = ${BASE_INSTRUMENTED_IMAGE}"
    echo "BASE_WORK_IMAGE_NAME = ${BASE_WORK_IMAGE_NAME}"
    echo "WORK_DIR = ${WORK_DIR}"
    echo "OUTPUT_DIR = ${OUTPUT_DIR}"
    echo "VM_NAME = ${VM_NAME}"
    echo "USER_LOGIN = ${USER_LOGIN}"
    echo "USER_PWD = ${USER_PWD}"    
    echo "CLIP_VIRT_PATH = ${CLIP_VIRT_PATH}"
    echo "RESULT_PATH = ${RESULT_PATH}"
    echo "-------------------"
}

process_path() {
    local dir=$1
    declare -a path_part
    local path=$(echo "$dir" | tr "/" "\n")
    local index=0
    local currentpath=""
    local in_test_directory="no"
    
    for i in $path; do    
        path_part[$index]=$i;
        let "index=$index + 1"
    done
    
    echo ${path_part[$(($index - 1))]} | grep -q "T-.*"
    
    if [ $? -eq 1 ]; then 
        PACKAGE_NAME=${path_part[$(($index - 1))]}
        PACKAGE_CATEGORY=${path_part[$(($index - 2))]}
    else
        PACKAGE_NAME=${path_part[$(($index - 2))]}
        PACKAGE_CATEGORY=${path_part[$(($index - 3))]} 
        TEST_GROUP=${path_part[$(($index - 1))]} 
    fi
    
    index=0
    for i in $path; do
        currentpath=${currentpath}"/"$i;
        if [ $in_test_directory = "no" ]; then
            if [ -f "$currentpath/test_base.conf" ]; then
                in_test_directory="yes"
                conffiles_paths[0]="$currentpath/test_base.conf"
                ROOT_TEST_DIRECTORY=$currentpath
                index=1
            fi
        else
            if [ -f "$currentpath/test.conf" ]; then
                conffiles_paths[$index]="$currentpath/test.conf";
                let "index=$index + 1"
            fi
        fi
    done
    
    nb_conf_files=$index
}

# -------------------
# démarre le traitement du chemin
PATH_TO_TEST=$(readlink -f "$1")
PATH_TO_TEST=$(realpath "$PATH_TO_TEST")

process_path "${PATH_TO_TEST}"

# -------------------
# initialise les variables de configuration
for i in ${conffiles_paths[@]}; do
    source $i
done

if [ -z "$OUTPUT_DIR" ]; then
    echo "${BASENAME} : attention la variable OUTPUT_DIR n'est pas initialisée"
    exit 1
fi

ROOT_TEST_DIR_NAME=$(basename "${ROOT_TEST_DIRECTORY}") 
RESULT_PATH=$(echo ${PATH_TO_TEST} | sed "s/^.*$ROOT_TEST_DIR_NAME//g")
RESULT_PATH=$OUTPUT_DIR/$ROOT_TEST_DIR_NAME/$RESULT_PATH
    
