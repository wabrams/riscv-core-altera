.globl _start

_start:

COUNT:
addi x12, x12, 1
andi x12, x12, 255
sw x12, 0(x0)
j COUNT
