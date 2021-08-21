#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def get_mac():
    from glob import glob
    mac_list = []
    files_mac = glob("/sys/class/net/*/address")
    for fmac in files_mac:
        try:
            mac = open(fmac).readline()
            mac = mac.strip()
        except:
            mac = None
        if mac: mac_list.append(mac)

    if mac_list:
        mac_list = list(dict.fromkeys(mac_list))
        print (f'\nAll MAC: {mac_list}\n')
    else:
        print (f'\nAll MAC: ERROR\n')

if __name__ == '__main__':
    get_mac()
