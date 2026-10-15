# 86a-DOS

<p align="center">
  <img src="https://img.shields.io/badge/86a--DOS-Version%2011.0-black?style=for-the-badge" alt="86a-DOS Version 11.0">
  <img src="https://img.shields.io/badge/Architecture-x86%2016--bit-blue?style=for-the-badge" alt="x86 16-bit">
  <img src="https://img.shields.io/badge/Language-Assembly-orange?style=for-the-badge" alt="Assembly">
</p>

<p align="center">
  <b>Simple. Fast. Beautiful. Yours.</b>
  <br>
  Un sistema operativo independiente
</p>

---

### ╋━ 86a-DOS | MICRO86 COMPACT | EDICION : DOS ━╋

## ¿Qué es 86a-DOS?

**86a-DOS** es un sistema operativo experimental desarrollado por **ElPanitaXD**, escrito principalmente en ensamblador x86 de 16 bits.

El proyecto incluye un cargador de arranque propio, un kernel y una interfaz gráfica para facilitar la exploracion.

## Características

- Sistema operativo experimental de 16 bits.
- Kernel desarrollado en ensamblador NASM.
- Arranque mediante un bootloader propio.
- Interfaz gráfica inspirada en Macintosh System 1.
- Terminal con comandos integrados.
- Gestión básica de teclado y mouse mediante servicios BIOS.
- Aplicaciones y juegos incluidos.
- Imagen de disco `86a_floppy.img`.
- Ejecución y compilación automatizadas mediante `Arrancar_Micro86.bat`.

## Cómo ejecutar 86a-DOS

No necesitás escribir manualmente los comandos de compilación.

### Método rápido

1. Descargá o cloná este repositorio.
2. Comprobá que los archivos del proyecto estén en la misma carpeta y que NASM y QEMU estén instalados y disponibles para el script.
3. Abrir el **`Arrancar_Micro86.bat`**.
4. Esperá a que se ensamble el kernel, se genere la imagen de disco y se abra QEMU.

El archivo por lotes automatiza el proceso de compilación y arranque.

```text
86a-DOS/
├── Arrancar_Micro86.bat
├── boot.asm
├── kernel.asm
├── boot.bin
├── kernel.bin
└── 86a_floppy.img
```

Los archivos `.bin` y la imagen `.img` pueden generarse automáticamente durante el proceso, según el contenido del script.

### Requisitos

- **Sistema anfitrión:** Windows.
- **NASM:** ensamblador utilizado para compilar los archivos `.asm`.
- **QEMU:** emulador de hardware para ejecutar el sistema.
- **Arranque:** imagen de disco generada por el script.

Descargas oficiales:

- [NASM](https://www.nasm.us/)
- [QEMU](https://www.qemu.org/download/)

> **Importante:** si el script no encuentra NASM o QEMU, revisá sus rutas de instalación y la configuración de `Arrancar_Micro86.bat`.

## Comandos de la terminal

Escribí el comando en la terminal y presioná **ENTER**.

| Comando | Función |
|---|---|
| `help` | Muestra la ayuda y los comandos disponibles. |
| `ver` | Muestra la versión del sistema. |
| `about` | Información sobre 86a-DOS. |
| `info` | Muestra información del sistema. |
| `mem` | Muestra información básica de memoria. |
| `cls` | Limpia y reconstruye la pantalla del sistema. |
| `clear` | Hace lo mismo que `cls`. |
| `echo texto` | Imprime un mensaje. |
| `color` | Permite cambiar el color de la terminal, si está habilitado. |
| `prompt texto` | Personaliza el indicador de comandos. |
| `time` | Muestra la hora del reloj BIOS. |
| `date` | Muestra la fecha del reloj BIOS. |
| `calc 2+2` | Realiza cálculos básicos. |
| `beep` | Emite un pitido cuando el entorno lo permite. |
| `dir` | Muestra el directorio virtual. |
| `type archivo` | Muestra el contenido de un archivo virtual. |
| `write` | Abre la función de escritura disponible en esta versión. |
| `del` | Ejecuta la función de eliminación disponible en esta versión. |
| `game` | Inicia el juego matemático. |
| `guess` | Juego de adivinar un número. |
| `react` | Juego de reflejos. |
| `finder` | Abre el explorador de archivos integrado. |
| `paint` | Abre la aplicación de dibujo. |
| `clock` | Abre la aplicación del reloj. |
| `notepad` | Abre el bloc de notas integrado. |
| `reboot` | Reinicia el sistema, si el entorno lo permite. |
| `shutdown` | Intenta apagar el sistema mediante los servicios de energía disponibles. |

*La disponibilidad y el comportamiento exacto de los comandos dependen de la versión del kernel incluida en el repositorio.*

## Aplicaciones

### Finder

Explorador básico para consultar los archivos virtuales del sistema.

### Paint

Aplicación de dibujo con una interfaz gráfica monocromática.

**Controles:**

| Tecla | Acción |
|---|---|
| `W` | Mover hacia arriba. |
| `A` | Mover hacia la izquierda. |
| `S` | Mover hacia abajo. |
| `D` | Mover hacia la derecha. |
| `ENTER` | Dibujar en la posición actual. |
| `ESC` | Cerrar Paint. |

### Clock

Aplicación gráfica para consultar la fecha y la hora.

### Notepad

Aplicación básica para visualizar texto.

## Juegos

- **Game:** pequeños ejercicios matemáticos.
- **Guess:** intenta adivinar un número dentro del rango indicado.
- **React:** poné a prueba tus reflejos y reaccioná cuando aparezca la señal.

## La filosofía de Micro86 Compact

Micro86 Compact es el concepto de computadora física pensado para ejecutar 86a-DOS.

Su diseño está inspirado en la estética de los Macintosh originales:

- Carcasa compacta color beige.
- Pantalla integrada.
- Teclado y mouse.
- Interfaz gráfica monocromática.
- Diseño industrial retro.

La computadora física es un proyecto complementario: **QEMU permite desarrollar y probar el sistema sin necesidad de construir primero el hardware**.

## Solución de problemas

**QEMU muestra `Boot failed`.**

Comprobá que la imagen de disco se haya generado correctamente y que el bootloader esté leyendo el kernel desde los sectores esperados.

**NASM no se encuentra.**

Instalá NASM y revisá que `Arrancar_Micro86.bat` apunte a su ubicación correcta.

**QEMU no se abre.**

Comprobá la instalación de QEMU y la ruta al ejecutable `qemu-system-x86_64.exe`.

**La pantalla queda negra.**

Revisá los errores de compilación y el proceso de carga del kernel antes de cambiar el código de la interfaz.

## Créditos

- **Desarrollador:** ElPanitaXD.
- **Proyecto:** 86a-DOS.
- **Computadora conceptual:** Micro86 Compact.
- **Lenguaje:** ensamblador x86 mediante NASM.

---

<p align="center">
  <b>86a-DOS</b>
  <br>
  Simple. Fast. Beautiful. Yours.
</p>

