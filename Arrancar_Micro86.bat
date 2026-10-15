@echo off
title Lanzador Oficial - Micro86 Compact
cd %userprofile%\Desktop

echo [1/3] Compilando el Sector de Arranque con NASM...
"C:\Users\%username%\AppData\Local\bin\NASM\nasm.exe" -f bin boot.asm -o boot.bin

echo [2/3] Compilando el Kernel Grafico con NASM...
"C:\Users\%username%\AppData\Local\bin\NASM\nasm.exe" -f bin kernel.asm -o kernel.bin

echo [3/3] Uniendo binarios en la imagen 86a_floppy.img...
powershell -Command "[System.IO.File]::WriteAllBytes('86a_floppy.img', [System.IO.File]::ReadAllBytes('boot.bin') + [System.IO.File]::ReadAllBytes('kernel.bin'))"

echo 🚀 Encendiendo el Micro86 Compact en QEMU...
"C:\msys64\ucrt64\bin\qemu-system-x86_64.exe" -drive format=raw,file=86a_floppy.img,if=floppy

echo.
echo Proceso terminado.
pause
