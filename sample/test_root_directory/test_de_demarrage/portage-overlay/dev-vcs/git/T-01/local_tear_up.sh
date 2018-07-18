#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.


user_login_to_vm tmp_vm

if [ $? -ne 0 ]; then
    fail "echec au login de la session utilisateur"
fi
