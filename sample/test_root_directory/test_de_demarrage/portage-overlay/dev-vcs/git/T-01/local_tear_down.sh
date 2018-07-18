#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

sh_to_vm "rm /vservers/rm_b/user_priv/home/git_version.txt"

user_logout_from_vm tmp_vm

if [ $? -ne 0 ]; then
    fail "echec au logout de la session utilisateur"
fi 
