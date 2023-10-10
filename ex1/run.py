import sys

import pyfiglet

if len(sys.argv) < 2:
    print("Usage: python run.py '<text>'")
    sys.exit(1)

text = " ".join(sys.argv[1:])

print(pyfiglet.figlet_format(text, font="standard"))