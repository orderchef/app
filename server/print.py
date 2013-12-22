#!/usr/bin/python
# coding=UTF8

from escpos import *
import logging
from socketIO_client import SocketIO, BaseNamespace
import sys
import socket

logging.basicConfig(level=logging.ERROR)

serverIP = "192.168.1.23"
serverPort = 8080

printerName = "Receipt Printer"
ip = socket.gethostbyname(socket.gethostname())

print ip

p = printer.Usb(0x4348, 0x5584, 0, 0x82, 0x01)

class PrintNamespace(BaseNamespace):
    def on_connect(self):
        print 'I LOVES HIM!'
        sock.emit('register', { 'ip': ip, 'name': printerName })
    
    def print_data(*args):
        print 'printing ', args
        
        data = args.data.split('\n')
        for line in data:
            p.text(data)

sock = SocketIO(serverIP, serverPort, PrintNamespace)
sock.wait()