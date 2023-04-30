ASM=nasm

.PHONY: all dir bin run

BIN=bin

all: dir $(BIN)/bootloader.bin $(BIN)/filetable.bin $(BIN)/kernel.bin os.bin

dir:
	mkdir -p bin

$(BIN)/bootloader.bin: boot.asm
	$(ASM) $< -f bin -o $@

$(BIN)/kernel.bin: kernel.asm
	$(ASM) $< -f bin -o $@

$(BIN)/filetable.bin: filetable.asm
	$(ASM) $< -f bin -o $@

$(BIN)/test.bin: programs/test.asm	
	$(ASM) $< -f bin -o $@

$(BIN)/gfx.bin: programs/gfx.asm
	$(ASM) $< -f bin -o $@

$(BIN)/malmi.bin: programs/malmi.asm
	$(ASM) $< -f bin -o $@
	
os.bin: $(BIN)/bootloader.bin $(BIN)/kernel.bin $(BIN)/filetable.bin $(BIN)/test.bin $(BIN)/malmi.bin
	cat $^ > $@

run: all	
	qemu-system-i386 -fda os.bin