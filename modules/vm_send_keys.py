#!/usr/bin/python
# -*- coding: utf-8 -*-
# SPDX-License-Identifier: LGPL-2.1-or-later
# Copyright © 2016-2018 ANSSI. All Rights Reserved.

"""
    Envoi une combinaison de touches : option key
    ou une chaine de caractères : option string
    à la VM dont le nom est passé en paramètre.
"""

import libvirt
import argparse


def build_table():
    table={}
    table["a"]=[16]
    table["b"]=[48] 
    table["c"]=[46]
    table["d"]=[32]
    table["e"]=[18]
    table["f"]=[33]
    table["g"]=[34]
    table["h"]=[35]
    table["i"]=[23]
    table["j"]=[36]
    table["k"]=[37]
    table["l"]=[38]
    table["m"]=[39]
    table["n"]=[49]
    table["o"]=[24]
    table["p"]=[25]
    table["q"]=[30]
    table["r"]=[19]
    table["s"]=[31]
    table["t"]=[20]
    table["u"]=[22]
    table["v"]=[47]
    table["w"]=[44]
    table["x"]=[45]
    table["y"]=[21]
    table["z"]=[17]
    table["A"]=[54,16]
    table["B"]=[54,48]
    table["C"]=[54,46]
    table["D"]=[54,32]
    table["E"]=[54,18]
    table["F"]=[54,33]
    table["G"]=[54,34]
    table["H"]=[54,35]
    table["I"]=[54,23]
    table["J"]=[54,36]
    table["K"]=[54,37]
    table["L"]=[54,38]
    table["M"]=[54,39]
    table["N"]=[54,49]
    table["O"]=[54,24]
    table["P"]=[54,25]
    table["Q"]=[54,30]
    table["R"]=[54,19]
    table["S"]=[54,31]
    table["T"]=[54,20]
    table["U"]=[54,22]
    table["V"]=[54,47]
    table["W"]=[54,44]
    table["X"]=[54,45]
    table["Y"]=[54,21]
    table["Z"]=[54,17]
    table["<"]=[86]
    table[">"]=[54,86]
    table[","]=[50]
    table[";"]=[51]
    table[":"]=[52]
    table["!"]=[53]
    table["?"]=[54,50]
    table["."]=[54,51]
    table["/"]=[54,52]
    table["§"]=[54,53]
    table[" "]=[57]
    table["1"]=[54,2]
    table["2"]=[54,3]
    table["3"]=[54,4]
    table["4"]=[54,5]
    table["5"]=[54,6]
    table["6"]=[54,7]
    table["7"]=[54,8]
    table["8"]=[54,9]
    table["9"]=[54,10]
    table["0"]=[54,11]
    table["&"]=[2]
    table["é"]=[3]
    table["\\"]=[4]
    table["'"]=[5]
    table["("]=[6]
    table["-"]=[7]
    table["è"]=[8]
    table["_"]=[9]
    table["ç"]=[10]
    table["à"]=[11]
    table[")"]=[12]
    table["°"]=[54,12]
    table["="]=[13]
    table["}"]=[100,13]
    table["{"]=[100,5]
    table["["]=[100,6]
    table["|"]=[100,7]
    table["^"]=[100,10]
    table["@"]=[100,11]
    table["]"]=[100,12]
    table["}"]=[100,13]
    table["œ"]=[41]
    #table["0"]=[82]
    table["."]=[83]
    #table["1"]=[79]
    #table["2"]=[80]
    #table["3"]=[81]
    #table["4"]=[75]
    #table["5"]=[76]
    #table["6"]=[77]
    #table["7"]=[71]
    #table["8"]=[72]
    #table["9"]=[73]
    table["/"]=[98]
    table["*"]=[55]
    table["-"]=[74]
    table["+"]=[78]
    table["F1"]=[59]
    table["F2"]=[60]
    table["F3"]=[61]
    table["F4"]=[62]
    table["F5"]=[63]
    table["F6"]=[64]
    table["F7"]=[65]
    table["F8"]=[66]
    table["F9"]=[67]
    table["F10"]=[68]
    table["F12"]=[88]
    table["enter"]=[28]
    table["leftalt"]=[56]
    table["altgr"]=[100]
    table["leftctrl"]=[29]
    table["rightctrl"]=[97]
    table["$"]=[27]
    table["esc"]=[1]
    return table


# domain_name : le nom du domaine
# retourne connexion, domaine
def get_domain(domain_name):
    connexion=libvirt.open("qemu:///system")
    if connexion==None:
        print("Failed to connect to qemu:///system")
        exit(1)
    
    dom=connexion.lookupByName(domain_name)
    if dom==None:
        print("Failed to get the domain object "+domain_name)
        connexion.close()
        exit(1)
    
    return connexion, dom


"""
    keys_combi : a string of the form "char1+char2..."
    example : "leftalt+F2"
"""
def send_keys(keys_combi, dom):
    table = build_table()
    nb_char_inavailable_in_table=0
    keys=[]
    key_codes=[]
    if (keys_combi == None):
        return 1
    if (keys_combi == ""):
        return 1
    keys=keys_combi.split("+")
    
    # check that keys are available in the table
    for key in keys:
        if (key not in table):
            print "key : "+key+" is not available in table"
            nb_char_inavailable_in_table=nb_char_inavailable_in_table+1
            
    if (nb_char_inavailable_in_table != 0):
        print "some keys are not available in table"
        return 1
    
    for key in keys:
        key_codes.extend(table[key])
        
    dom.sendKey(0,0,key_codes,len(key_codes),0)
    return 0

def send_string(string_to_send, dom):
    table = build_table()
    nb_char_inavailable_in_table=0
    
    # teste si tous les caractères de la chaine sont disponibles
    if (string_to_send == None):
        return 1
    if (string_to_send == ""):
        return 1
    
    for ch in string_to_send:
        if (ch not in table):
            nb_char_inavailable_in_table=nb_char_inavailable_in_table+1
            print "character :"+ch+" is not avalaible"
    
    if (nb_char_inavailable_in_table != 0):
        print "some characters are not available"
        return 1
    
    for ch in string_to_send:
        dom.sendKey(0,0,table[ch],len(table[ch]),0)
    return 0

def build_arg_parser():
    parser=argparse.ArgumentParser(description="Envoi de caractères à une vm")
    parser.add_argument("vm_name", metavar="VM_NAME", help="nom de la vm")
    parser.add_argument("choice", choices=["key","string"])
    parser.add_argument("string", metavar="DATA_TO_SEND", help="string/key à envoyer, par exemple word/leftalt+F2")
    return parser

def main(main_args):    
    connex, dom = get_domain(main_args.vm_name)
    code_retour = 0
    if (dom == None):
        print "can't get the domain :" + vm_name
        connex.close()
        exit(1)
    
    if (main_args.choice == "string"):
        code_retour = send_string(main_args.string, dom)
    else:
        code_retour = send_keys(main_args.string, dom)
    
    connex.close()
    exit (code_retour)

if __name__ == "__main__":
    parser = build_arg_parser()
    args = parser.parse_args()
    main(args)
