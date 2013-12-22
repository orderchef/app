#from escpos import *
import logging
from socketIO_client import SocketIO, BaseNamespace
import sys
import socket

logging.basicConfig(level=logging.ERROR)

printerName = "Receipt Printer"
ip = socket.gethostbyname(socket.gethostname())

print ip

#p = printer.Serial("/dev/ttyAMA0", 19200, 8, 0)

class PrintNamespace(BaseNamespace):
    def on_connect(self):
        print 'I LOVES HIM!'
        sock.emit('register', { 'ip': ip, 'name': printerName })
    
    def print_data(*args):
        print 'printing ', args
        
        data = args.data.split('\n')
        for line in data:
            p.text(data)

sock = SocketIO('127.0.0.1', 8080, PrintNamespace)
sock.wait()