#!/usr/bin/python
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

import vm_console
import vm_send_keys
import time
import traceback
import re
import argparse
import sys

"""
    tente de se logger et ouvrir une session rm_b et l'application konsole en partant du démarrage d'une vm
    retourne True si il y parvient sans qu'un des timeout ne soit dépassé :
    - disponibilité de l'écran de connexion
    - démarrage de la session
    - démarrage de konsole
    retourne False si un timeout est dépassé
"""
def login(vm_name, login, passwd):
    connexion = None
    domain = None
    ret = 0
    
    try:
        connexion, domain = vm_console.get_connexion_and_domain(vm_name)        
        # attend le démarrage de la vm
        succeed = vm_console.wait_for_terminal_ready(domain,120)
        if (not succeed):
            print "VM not ready"
            return 1
        
        time.sleep(1)
        
        # tente d'ouvrir une session (3 essais par défaut)
        succeed = try_to_login(domain, login, passwd, 120)
        if (not succeed):
            print "rm_b session doesn't start"
            return 1
                                         
        # tente d'ouvrir la konsole.
        succeed = try_to_open_konsole(domain, 40)
        if (not succeed):
            print "konsole doesn't start"
            return 1
                
    except Exception as e:
        print "error : "+str(e)+"\n"
        traceback.print_exc()
        if (connexion != None):
            connexion.close()
        return 1

    if (connexion != None):
        connexion.close()
    return ret


"""
    essaie d'ouvrir une session :
    timeout : le temps max d'ouverture de la session un fois log/passwd envoyé
    nbretry : le nombre d'essais dans le cas où le timeout est dépassé
"""
def try_to_login(domain, login, passwd, timeout=120, nbretry=3):
    nb_try = 0
    
    while (nb_try < nbretry):
        print "try "+str(1+nb_try)+" of "+str(nbretry)
        # entre login/passwd.
        vm_send_keys.send_string(login, domain)
        vm_send_keys.send_keys("enter", domain)
        vm_send_keys.send_string(passwd, domain)
        vm_send_keys.send_keys("enter", domain)
        
        ## attend que la session soit prête.
        succeed = vm_console.wait_for_user_session(domain,"rm_b",timeout)
        if (succeed):
            return True
        nb_try=nb_try+1

    return False

"""
    essaie d'ouvrir une konsole pendant time_out, en lui laissant 2 secondes pour se lancer
    retourne True : si cela a fonctionné avant la fin du time_out
    retourne False : si la konsole n'est pas lancée au bout du time_out
"""
def try_to_open_konsole(domain, time_out = 3): 
    start_time=time.time()
    
    chercheur=re.compile("kdeinit")

    while(True):        
        print "try to launch konsole"
        vm_send_keys.send_keys("esc", domain)
        vm_send_keys.send_keys("leftalt+F2",domain)
        vm_send_keys.send_string("konsole", domain)
        vm_send_keys.send_keys("enter", domain)
        
        time.sleep(2)
        output,ret_code=vm_console.send_command(domain, "vsctl rm_b enter -c user -- /bin/ps | grep konsole")
        res_recherche = chercheur.search(output)
        if (res_recherche != None):
            return True
        if (time.time() > start_time+time_out):
            return False
        
    return False
        

def test_if_rmb_session_opened(domain):
    # teste si konsole est lancé
    chercheur = re.compile("kdeinit")
    output,ret_code=vm_console.send_command(domain, "vsctl rm_b enter -c user -- /bin/ps | grep krunner")
    res_recherche = chercheur.search(output)
    if (res_recherche != None):
        return True    
    return False


def test_if_rmb_session_and_konsole_opened(domain):    
    # teste si konsole est lancé
    chercheur = re.compile("kdeinit")
    output,ret_code=vm_console.send_command(domain, "vsctl rm_b enter -c user -- /bin/ps | grep konsole")
    res_recherche = chercheur.search(output)
    if (res_recherche != None):
        return True    
    return False
    
"""
    retourne à l'écran de connexion
"""
def logout(vm_name):
    connexion = None
    domain = None
    ret_code = 0
    
    try:
        connexion, domain = vm_console.get_connexion_and_domain(vm_name)        
        output,ret_code=vm_console.send_command(domain, "vsctl rm_b enter -c user -- /bin/killall konsole")        
        output,ret_code=vm_console.send_command(domain, "vsctl user enter -- /bin/killall adeskbar") 
        
        print output
        
    except Exception as e:
        print "erreur : "+str(e)+"\n"
        traceback.print_exc()
        if (connexion != None):
            connexion.close()
        return 1
    
    return ret_code


def test():
    ret = login("tmp_vm")
    if (ret != 0):
        print "login error"
        exit(1)
        
    time.sleep(5)
    
    ret = logout("tmp_vm")
    if (ret != 0):
        print "logout error"
        exit(1)        

def main(commande,argslist):
       
    if (commande == "login"):
        parser=argparse.ArgumentParser(description="try to open user session and launch konsole")
        parser.add_argument("vm_name")
        parser.add_argument("login")
        parser.add_argument("passwd")
        args=parser.parse_args(argslist)
        code_retour = login(args.vm_name, args.login, args.passwd)
        exit(code_retour)
                
    if (commande == "logout"):
        parser=argparse.ArgumentParser(description="try to logout user session")
        parser.add_argument("vm_name")
        args=parser.parse_args(argslist)
        code_retour = logout(args.vm_name)
        exit(code_retour) 

if (__name__=="__main__") :
    parser=argparse.ArgumentParser()
    parser.add_argument("commande",choices=["login", "logout"], help="add -h after a command to get its help")
    if (len(sys.argv) < 2):
        parser.print_help()
        exit(1)
    args = parser.parse_args(sys.argv[1].split())
    main(args.commande, sys.argv[2:])


