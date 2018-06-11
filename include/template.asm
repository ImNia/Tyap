format ELF executable 3
include 'import32.inc'
include 'proc32.inc'

interpreter '/lib/ld-linux.so.2'
needed 'libc.so.6'
import printf,scanf,exit

segment readable executable
entry $
    finit
