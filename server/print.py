from escpos import *
import sys

print "Printing something.."
sys.stdout.flush()

Epson = printer.Serial("/dev/ttyAMA0", 19200, 8, 0)

for line in sys.stdin:
    print line
    sys.stdout.flush()
    Epson.text(line)

Epson.cut()