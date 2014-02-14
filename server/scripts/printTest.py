#!/usr/bin/python
# coding=UTF8

from escpos import *
import logging
import sys

p = printer.Usb(0x, 0x)

print "Print job sent"
string = u'USD $, GBP £, 台'
p.text(string)
p.text(string.encode('utf-8'))
p.cut()