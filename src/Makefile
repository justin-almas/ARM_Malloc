#target remote :1234
#arm-none-eabi-gdb


.PHONY: all
all: 
	arm-none-eabi-as -g -o malloc.o malloc.s
	arm-none-eabi-ld -o malloc.elf malloc.o

.PHONY: run
run: all
	qemu-arm -L /usr/arm-linux-gnueabihf malloc.elf


.PHONY: gdb
gdb: all
	qemu-arm -g 1234 -L /usr/arm-linux-gnueabihf malloc.elf

.PHONY: clean
clean:
	rm -f *.o *.elf	
