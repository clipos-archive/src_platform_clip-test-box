#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

# prend en paramètre le fichier de configuration contenant la description de la vm et des répertoires de travail 
# --------------------------------------------------------------------------------------------------------------

BASENAME="$(basename -- "$0")"

usage() {
    cat <<EOF
Usage:
${BASENAME} <path to the configuration file>
EOF
}

usage_exit() {
	usage
	exit 1
}

if [[ "${#}" -ne 1 ]]; then
    usage_exit
fi

CONFIGURATION_FILE="$1"

if [ ! -f "$CONFIGURATION_FILE" ]; then
    echo "le fichier de configuration $CONFIGURATION_FILE n'existe pas"
    exit 1
fi

source $CONFIGURATION_FILE

# creation de l'image de la VM
# ---------------------------------
cp $BASE_INSTRUMENTED_IMAGE "$WORK_DIR/$BASE_WORK_IMAGE_NAME"
chmod u+w "$WORK_DIR/$BASE_WORK_IMAGE_NAME"

# instantiate and start vm
# ---------------------------------
"$CLIP_VIRT_PATH"/clip-virt instantiate-vm $VM_NAME "$WORK_DIR$BASE_WORK_IMAGE_NAME"
