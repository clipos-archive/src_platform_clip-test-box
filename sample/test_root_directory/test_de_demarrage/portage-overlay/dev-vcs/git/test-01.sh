#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# -------------------------
# start the test
start_test_message "test installation git"


# test l'installation du paquetage git
# --------------------------------------
echo "test de l'installation du paquetage git"

OUTPUT=$(sh_to_vm "ls /vservers/rm_b/update_priv/usr_local/bin/git")
POS=$(expr index "$OUTPUT" "/vservers/rm_b/update_priv/usr_local/bin/git")

if [ "$POS" != "0" ]; then
    success "git est bien installé"
else
    echo "installation de git"
fi

# test du démarrage du sdk
# --------------------------------------
SDK_STARTED=$(is_lxc_started clip4)

if [ "$SDK_STARTED" != "1" ]; then
    error "le sdk clip4 n'est pas démarré"
fi

RES=""

# ---------------------------------------------------------
# compile git et ses dépendances et les installe
$CLIP_VIRT_PATH/clip-virt deploy-pkg clip4 $VM_NAME rm_b git
RES=$($CLIP_VIRT_PATH/clip-virt sh-to-vm $VM_NAME "echo $?")
echo
echo "resultat = $RES"

# ----------------------
if [ "$RES" = "0" ]; then
    success
else
    error
fi
