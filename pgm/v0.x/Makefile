# RISC-V DEFINES
GCC     = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump
# COMPILER SETTINGS
CFLAG   = -nostartfiles -nostdlib -march=rv32i -mabi=ilp32
LINKER  = linker.lk
# OBJDUMP FLAGS
DFLAG = -d -M no-aliases,numeric

count: count.o
	${OBJCOPY} -O binary count.o count.bin
	${OBJCOPY} -S -O ihex count.o count.hex
	${OBJDUMP} ${DFLAG} count.o

count.o:
	${GCC} ${CFLAG} -T ${LINKER} count.s -o count.o

clean:
	rm *.bin *.hex *.o
