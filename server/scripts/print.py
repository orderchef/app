#!/usr/bin/python
# coding=UTF8

from escpos import *
import logging
from socketIO_client import SocketIO, BaseNamespace
import sys
import socket

logging.basicConfig(level=logging.ERROR)

serverIP = "192.168.1.103"
serverPort = 8000
#it is a receipt printer
printsBill = True
#shows prices..
prices = False
#40 characters, change!
characters = 40

printerName = "Receipt Printer"
ip = socket.gethostbyname(socket.gethostname())

print ip

p = printer.Usb(0x4348, 0x5584, 0, 0x82, 0x01)

class PrintNamespace(BaseNamespace):
    def on_connect(self):
        print 'I LOVES HIM!'
        sock.emit('register', {
            'ip': ip,
            'name': printerName,
            'printsBill': printsBill,
            'prices': prices,
            'characters': characters
        })
    
def print_data(*args):
    print 'printing ', args
    
    if 'logo' in args[0] and args[0]['logo'] == True:
        p.set('center')
        p.image("logo.jpg")
        p.set('left')
    
    if 'address' in args[0] and args[0]['address'] == True:
        p.text("\n")
        p.set('center', 'a', 'b')
        p.text("100 Cowley Road, Oxford, OX4 1JE\n")
        p.text("01865 434100\n")
        p.set('left', 'a', 'normal')
    
    #data = args[0]['data'].split('\n')
    #for line in data:
    #    p.text(line.encode('utf-8')+'\n')
    p.text(args[0]['data'].encode('utf-8'));
    
    if 'footer' in args[0] and args[0]['footer'] == True:
        p.text("\n")
        p.set('center', 'a', 'b')
        p.text("Service Charge not Included. Thank you")
        p.set('left', 'a', 'normal')
    
    p.cut()

sock = SocketIO(serverIP, serverPort, PrintNamespace)
sock.on('print_data', print_data)
sock.wait()
