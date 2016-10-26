OPENDLX=/cal/homes/brandner/opt/openDLX-1.0/bin/openDLX
MIPS_CC=/cal/homes/brandner/opt/mips-2015.11/bin/mips-linux-gnu-gcc
MIPS_OBJCPY=/cal/homes/brandner/opt/mips-2015.11/bin/mips-linux-gnu-objcopy

MIPS_CFLAGS=-g -Wall -O0 -fno-builtin -mips32 -EL -nostdlib -nostartfiles -static -Ttext 0x1000

.PHONY: all run clean

all: bin/bsort.bin cfg/*.cfg

run: bsort_bp_2bit_saturation.log bsort_bp_1bit.log

bin/bsort.elf: src/bsort.c
	$(MIPS_CC) $(MIPS_CFLAGS) -o $@ $<

bin/bsort.bin: bin/bsort.elf
	$(MIPS_OBJCPY) -O binary -S $< $@

cfg/*.cfg: bin/bsort.elf
	bin/updatecfgFiles.sh $< ./cfg > /dev/null 2>&1

%.log: cfg/%.cfg bin/bsort.bin
	$(OPENDLX) -c cfg/$*.cfg


clean:
	rm -f bin/bsort.elf bin/bsort.bin *.log
