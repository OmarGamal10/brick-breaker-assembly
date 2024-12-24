import os
import subprocess
from time import sleep

filedata = r"""
[cpu]
cycles = max
[sdl]
fullresolution=640x400
windowresolution=640x400
output=openglpp
[autoexec]
mount C C:\\8086
C:
tasm /m2 *.asm
link MainMenu.obj Bricks.obj bar.obj ball.obj;
"""

filedata += "\nMainMenu.exe"

filedata1 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM1
    """
)

filedata2 = (
    filedata
    + r"""
[serial]
serial1=directserial realport:COM2
    """
)

with open("dosbox-x-generated1.conf", "w") as file:
    file.write(filedata1)

with open("dosbox-x-generated2.conf", "w") as file:
    file.write(filedata2)

prog1 = ["C:\\Program Files (x86)\\DOSBox-0.74-3\\DOSBox.exe", "-conf", "dosbox-x-generated1.conf"]
prog2 = ["C:\\Program Files (x86)\\DOSBox-0.74-3\\DOSBox.exe", "-conf", "dosbox-x-generated2.conf"]

subprocess.Popen(prog1)
sleep(5)
subprocess.Popen(prog2)