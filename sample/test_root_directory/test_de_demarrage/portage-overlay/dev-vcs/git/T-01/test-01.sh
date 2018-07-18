#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

start_test_message

send_string_to_vm "git --version &> git_version.txt"

if [ $? -ne 0 ]; then
    fail "echec a l'envoi de la chaine : git --version &> git_version.txt"
fi

send_key_to_vm "enter"

if [ $? -ne 0 ]; then
    fail "echec a l'envoi de la touche : enter"
fi

# récupération du fichier résultat via la connexion série
sh_to_vm "vsctl rm_b enter -c user -- /bin/mv /home/user/git_version.txt /home"
if [ $? -ne 0 ]; then
    fail "echec au deplacement du fichier resultat"
fi

OUTPUT=$(sh_to_vm "cat /vservers/rm_b/user_priv/home/git_version.txt")
RET_CODE="$?"

RETOUR="$OUTPUT$RET_CODE"
RESULT_ATTENDU=$(cat "$TESTPATH/resultat_attendu_test-01.txt")

if [ "$RETOUR" = "$RESULT_ATTENDU" ]; then
    success "la bonne version de git est bien installée"
else
    error "$RETOUR
au lieu de 
$RESULT_ATTENDU"
fi
