# ASM-Chess

This is an ascii-version of the well-known chess game written in x86 assembler with a simple AI. It
is meant to run on the [Casio Algebra FX 2.0 calculator](https://www.casio-intl.com/asia/en/calc/products/ALGEBRAFX2.0PLUS/), but it also works on DOS, old Windows versions (up to Windows XP?) and [DOSBox](https://www.dosbox.com/) as well as other emulators like [DOSBox Turbo for Android](https://play.google.com/store/apps/details?id=com.fishstix.dosbox&hl=de&gl=US).

![Screenshot first moves](screenshot.png)

## Compile

Use [NASM](https://www.nasm.us/) to compile for DOS.

## Playing instructions

The field is ASCII-based, with German abbrevations for the pieces:

* `b`: "Bauer", pawn
* `d`: "Dame", queen
* `k`: "König", king
* `s`: "Springer", knight
* `t`: "Turm", rook
* `l`: "Läufer", bishop

Lower case are your pieces (white), upper case are the opponents/AI pieces (black).

Use four digits to move a piece: column/row/destination column/destination row. For example: `5755` moves white pawn to steps ahead as opening move.

To quit the game, press 9.
