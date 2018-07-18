#!/usr/bin/python
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

import libvirt
import sys
from xml.dom import minidom
import re
import serial
import time
import argparse


"""
    NB pour exécuter une commande dans une cage il suffit d'utiliser un appel de la forme :
    vsctl rm_b enter -c user -- /bin/cat /home/titi.txt
"""


"""
    domain_name : le nom du domaine
    retourne les instances de connexion et domain
"""
def get_connexion_and_domain(domain_name):
    connexion=libvirt.open("qemu:///system")
    if connexion==None:
        raise Exception("Failed to connect to qemu:///system")
    
    dom=connexion.lookupByName(domain_name)
    if dom==None:
        connexion.close()
        raise Exception("Failed to get the domain object "+domain_name)    
    
    return connexion, dom


"""
    retourne le nom du port serie a utiliser
"""
def get_serial_port_name(domain_instance):    
    raw_xml = domain_instance.XMLDesc(0)
    prog=re.compile("<console type='pty' tty='(.*?)'>")
    result=prog.search(raw_xml)
    if (result == None):
        raise Exception("can't find tty console in the vm")        
    
    nom = result.group(1)       
    return nom


"""
    crée le port série à partir de son nom
"""
def create_serial_port_object(serial_name):
    ser=serial.Serial(serial_name)
    if (ser == None):
        raise Exception("error while creating the serial port "+serial_name)        
    ser.baudrate=115200
    ser.rtscts=True    
    ser.bytesize=8
    ser.stopbits=1
    ser.timeout=0
    return ser


"""
    send_command(domain, command, timeout_sec=0)
    domain : l'instance de domaine
    command : le texte de la commande bash
    timeout_sec : le paramètre passé à la fonction bash timeout qui appelle la commande passée en argument si il est non nul
    retourne : le texte de la sortie, le $?
"""
def send_command(domain, command, timeout_sec=0):    
    resultat=""

    serialport_name=get_serial_port_name(domain)

    if (serialport_name == ""):
        raise Exception("Cannot get the serial port name")

    serialport=create_serial_port_object(serialport_name)

    if (serialport == None):
        raise Exception("Cannot create the serial port of name "+serialport_name)        

    serialport.write("clear\n")
    serialport.flush()
    
    serialport.reset_output_buffer()
    serialport.reset_input_buffer()
    serialport.flush()
    
    if (timeout_sec == 0):
        serialport.write(command+" ; echo $? ; printf %s fin input\n")
        serialport.flush()
    else:
        serialport.write("timeout "+str(timeout_sec)+" " + command + " ; echo $? ; printf %s fin input\n")
        serialport.flush()

    cherche_fininput = re.compile("fininput")

    lecture=""

    while (True):
        lecture = lecture + serialport.read(1)
        res = cherche_fininput.search(lecture)
        if (res != None):
                break
    
    lignes = lecture.split("\n")   
    
    if (len(lignes) < 3):
        serialport.reset_output_buffer() 
        serialport.close()
        return "", -1
    
    # on supprime la première et la dernière ligne    
    lignes_resultat=lignes[1:len(lignes)-2]
    
    # on récupère le code de retour
    code_retour = int (lignes[len(lignes)-2])
    
    for ligne in lignes_resultat:
        line_end="\n"
        if ((ligne == "") or (ligne[len(ligne)-1] == '\n')):
            line_end=""
        resultat = resultat+ligne+line_end

    serialport.reset_input_buffer()                
    serialport.reset_output_buffer() 
    serialport.close()
    return resultat, code_retour

    

"""
    teste si le terminal à l'autre bout du port série est fonctionnel
    domain : l'instance d'objet domain
    test_delay_sec : le temps d'attente de la réponse en provenance du terminal, par défaut 1 seconde
    retourne True si la console est prête avant le timeout
"""
def is_terminal_ready(domain, test_delay_sec=1):
    start_time = 0
    
    try:
        serialport_name=get_serial_port_name(domain)
    except Exception as e:
        print ("is_terminal_ready : "+str(e))
        return False
   
    if (serialport_name == ""):
        print ("is_terminal_ready : Can't get the name of the serial port")
        return False

    try :
        serialport=create_serial_port_object(serialport_name)
    except Exception as e:
        print ("is_terminal_ready : "+str(e))
        return False
        
    serialport.nonblocking()
    
    serialport.write("printf %s test delaconsole\n")
    serialport.flush()

    cherche_test = re.compile("testdelaconsole")

    lecture=""

    start_time = time.time()

    while (True):
        time.sleep(0.001)
        lecture = lecture + serialport.read(1)
        res = cherche_test.search(lecture)
        if (res != None):
                break
        if (time.time() > (start_time + test_delay_sec) ):
            serialport.close()
            return False
        
    serialport.reset_output_buffer()
    serialport.reset_input_buffer()                    
    serialport.close()
    return True
   
"""
    teste si la session rm_b est bien ouverte en vérifiant que le résultat de :
    "vsctl rm_b enter -c user -- /bin/ps | grep krunner"
    contient bien au moins "kdeinit" c'est à dire kmix est lancé
    input :
        cage : "rm_b", "rm_h"
        domain : instance du domaine
        test_delay_sec : le temps d'attente de la réponse en provenance du terminal, par défaut 1 seconde
    retourne True si la session est prête avant le timeout    
"""
def is_session_ready(domain, cage_name, test_delay_sec=1):    
    output, ret_code = send_command(domain, "vsctl " + cage_name + " enter -c user -- /bin/ps | grep krunner", test_delay_sec)
    
    if (ret_code != 0):
        return False
    
    chercheur=re.compile("kdeinit")
    res_recherche=chercheur.search(output)
    
    if (res_recherche != None):
        return True

    return False


"""
    attend max_time_sec que le terminal soit prêt
    si il est prêt alors retourne True
    sinon retourne False
"""
def wait_for_terminal_ready(domain, max_time_sec=1):
    print "wait for terminal"
    start_time=time.time()
    while(True):
        if (time.time() > start_time+max_time_sec):
            print("Timeout reached and terminal not ready")
            return False
        if (is_terminal_ready(domain)):
            print("Terminal ready")
            return True
        print "time left : "+str(int(start_time+max_time_sec-time.time()))
    return False


"""
    attend max_time_sec que la session user pour la cage donnée soit ouverte
    on prend comme point de repère le lancement de kmix
    retourne au moins "Desktop lost+found"    
"""
def wait_for_user_session(domain, cage_name, max_time_sec=1):
    print "wait for user session"
    start_time=time.time()
    while(True):
        if (time.time() > start_time+max_time_sec):
            print("Timeout reached et user session not ready")
            return False
        if (is_session_ready(domain, cage_name)):
            print("Session ready")
            return True
        print "time left : "+str(int(start_time+max_time_sec-time.time()))
    return False
    



"""
    envoie une commande bash à la vm
    retourne la valeur de retour de la commande dans la vm
"""
def sh_to_vm(vm_name, command, timeout=0):  
    connex=None
    dom=None
    code_retour=0
    sortie=""
    
    try :
        connex,dom=get_connexion_and_domain(vm_name)
        sortie,code_retour=send_command(dom,command,timeout)
    except Exception as e:
        print "erreur : "+str(e)
        if (connex != None):
            connex.close()
        return 1
    
    print sortie
    connex.close()
    return code_retour


"""
    attend que l'os aie démarré jusqu'à ce qu'une console soit disponible
    retourne avec 0 si la console est prête avant le timeout
    retourne avec 1 si la console n'est pas prête au moement du timeout
"""
def wait_for_os_launch(vm_name, timeout=0):
    connex=None
    dom=None
    code_retour=0
    console_prete_avant_to=False
    local_timeout=timeout
    
    if (local_timeout==0):
        local_timeout = 60
        
    try :
        connex,dom=get_connexion_and_domain(vm_name)
        console_prete_avant_to=wait_for_terminal_ready(dom, local_timeout)
    except Exception as e:
        print "erreur : "+str(e)
        if (connex != None):
            connex.close()
        return 1
    
    connex.close()
    if (console_prete_avant_to):
        code_retour=0
    else:
        code_retour=1
        
    return code_retour
    
    

def main(commande,argslist):
    
    if (commande == "sh_to_vm"):
        parser=argparse.ArgumentParser(description="call the command in the vm, exit with the exit value of the vm")
        parser.add_argument("vm_name")
        parser.add_argument("command", help="put the command between brackets")
        parser.add_argument("-t", "--timeout", help="if the timeout is reach then the command is killed and the prog exit with 124")
        args=parser.parse_args(argslist)
        timeout=0
        if (args.timeout != None):
            timeout=int(args.timeout)
        code_retour = sh_to_vm(args.vm_name, args.command, timeout)
        exit(code_retour)
                
    if (commande == "wait_for_os_launch"):
        parser=argparse.ArgumentParser(description="wait for the given amount of time for the os to start in the vm, exit with 0 if started before timeout, 1 otherwise. Default timeout is 60 seconds")
        parser.add_argument("vm_name")
        parser.add_argument("-t", "--timeout")
        args=parser.parse_args(argslist)
        timeout=0
        if (args.timeout != None):
            timeout=int(args.timeout)
        code_retour = wait_for_os_launch(args.vm_name, timeout)
        exit(code_retour)
        
    

def test():
    connex=None
    dom=None
    domain_name="tmp_vm"

    try :
        connex,dom=get_connexion_and_domain(domain_name)
        
        if (not wait_for_terminal_ready(dom, 120)):
            print "le terminal n'est pas prêt"
            exit(1)
    
        resultat, code_retour = send_command(dom, "ls /", 0)        
        print resultat
        print "code retour : " + str(code_retour)
        resultat, code_retour = send_command(dom, "sleep 3", 1)        
        print resultat
        print "code retour : " + str(code_retour)        
    except Exception as e:
        print "erreur : "+str(e)
    finally:
        if (connex != None):
            connex.close()        
        
if (__name__=="__main__") :
    parser=argparse.ArgumentParser()
    parser.add_argument("commande",choices=["sh_to_vm", "wait_for_os_launch"], help="add -h after a command to get its help")
    if (len(sys.argv) < 2):
        parser.print_help()
        exit(1)
    args = parser.parse_args(sys.argv[1].split())
    main(args.commande, sys.argv[2:])
