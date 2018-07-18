#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# !! la variable BASENAME doit contenir le nom du script appelant.

# prend en argument le chemin vers le répertoire de test : 
# cad le répertoire global de test : categorie/paquetage ou le répertoire du groupe de test categorie/paquetage/T-x
init_global_var() {
    local PATH_TO_TEST
    PATH_TO_TEST=$(readlink -f "$1")
    PATH_TO_TEST=$(realpath "$PATH_TO_TEST")
    
    source test_main_config.sh "${PATH_TO_TEST}"
    
    if [ $? -ne 0 ]; then 
        echo "${BASENAME} : erreur à l'initialisation des variables globales"
        exit 1
    fi    
}

# prend en argument le chemin vers le répertoire de test : 
# cad le répertoire global de test : categorie/paquetage ou le répertoire du groupe de test categorie/paquetage/T-x
create_and_return_host_outputdir() {
    PATH_TO_TEST=$(realpath "$1")
    source test_main_config.sh "${PATH_TO_TEST}"

    if [ $? -ne 0 ]; then
        echo "${BASENAME} : erreur à l'initialisation"
        exit 1
    fi

    mkdir -p $RESULT_PATH
    
    echo $RESULT_PATH
}

# ----------------------------
# écrit le message de début de test
# prend en argument un commentaire optionnel
# pre : init_global_var doit avoir été appelé auparavant
start_test_message() {
    local RESULT_FILE_PATH="$RESULT_PATH/$(basename $TESTSCRIPT).start"
    echo "START : $(date)" > "$RESULT_FILE_PATH"

    if [[ "${#}" -ne 1 ]]; then
        MESSAGE="no message"
    else
        MESSAGE="$1"
    fi

    echo "$MESSAGE" >> "$RESULT_FILE_PATH"
}

# ----------------------------
# écrit le message de test réussi
# prend en argument un commentaire optionnel
# pre : init_global_var doit avoir été appelé auparavant
success() {
    local MESSAGE
    local RESULT_FILE_PATH="$RESULT_PATH/$(basename $TESTSCRIPT).result"
    
    if [[ "${#}" -ne 1 ]]; then
        MESSAGE="no message"
    else
        MESSAGE="$1"
    fi
    
    echo "SUCCESS : $(date)" > "$RESULT_FILE_PATH"
    echo "$MESSAGE" >> "$RESULT_FILE_PATH"
    exit 0
}

# ----------------------------
# écrit le message d'échec de test 
# prend en argument un commentaire optionnel
# pre : init_global_var doit avoir été appelé auparavant
fail() {
    local MESSAGE
    local RESULT_FILE_PATH="$RESULT_PATH/$(basename $TESTSCRIPT).result"
        
    if [[ "${#}" -ne 1 ]]; then
        MESSAGE="no message"
    else
        MESSAGE="$1"
    fi
    
    echo "FAILED : $(date)" > "$RESULT_FILE_PATH"
    echo "$MESSAGE" >> "$RESULT_FILE_PATH"    
    exit 0
}

# ----------------------------
# écrit le message d'erreur à l'exécution d'un test
# prend en argument un commentaire optionnel
# pre : init_global_var doit avoir été appelé auparavant
error() {
    local MESSAGE
    local RESULT_FILE_PATH="$RESULT_PATH/$(basename $TESTSCRIPT).result"
    
    if [[ "${#}" -ne 1 ]]; then
        MESSAGE="no message"
    else
        MESSAGE="$1"
    fi

    echo "ERROR : $(date)" > "$RESULT_FILE_PATH"
    echo "$MESSAGE" >> "$RESULT_FILE_PATH"
    exit 1
}

# --------------------------
# test si le lxc dont le nom est passé en argument est bien démarré
# prend en paramètre le nom de la vm
# écrit 1 si le lxc est démarré 
# écrit 0 si le lxc n'est pas démarré
is_lxc_started() {
    if [[ "${#}" -ne 1 ]]; then
        exit 1
    fi
    
    ps aux | grep "$1" | grep -q "lxc-start"
    
    if [ $? -eq 0 ]; then
        echo 1
        exit 0
    fi
    
    echo 0
}

send_key_to_vm() {
    if [[ "${#}" -ne 1 ]]; then
        exit 1
    fi

    ./vm_send_keys.py $VM_NAME key "$1"
}

send_string_to_vm() {
    if [[ "${#}" -ne 1 ]]; then
        exit 1
    fi

    ./vm_send_keys.py $VM_NAME string "$1"
}

sh_to_vm() {
    if [[ "${#}" -ne 1 ]]; then
        exit 1
    fi

    ./vm_console.py sh_to_vm $VM_NAME "$1"
}

user_login_to_vm() {
    if [[ "${#}" -ne 1 ]]; then
        exit 1
    fi

    ./vm_session.py login $VM_NAME $USER_LOGIN $USER_PWD
}

user_logout_from_vm() {
    if [[ "${#}" -ne 1 ]]; then
        exit 1
    fi

    ./vm_session.py logout $VM_NAME     
}


