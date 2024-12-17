@echo off

serial1=directserial realport:COM2

masm %1.asm
link %1.obj
%1.exe
