#---------------------------------------------------------------------------------
# the prefix on the compiler executables
#---------------------------------------------------------------------------------
PREFIX          :=      score-elf-

export CC       :=      $(PREFIX)gcc
export CXX      :=      $(PREFIX)g++
export AS       :=      $(PREFIX)as
export AR       :=      $(PREFIX)ar
export OBJCOPY  :=      $(PREFIX)objcopy
export STRIP    :=      $(PREFIX)strip
export NM       :=      $(PREFIX)nm
export RANLIB   :=      $(PREFIX)ranlib


TARGET	:=	uart-test

ARCH	:=	-mscore7 -mel -flto -O2
CFLAGS	:=	$(ARCH) -g
ASFLAGS	:=	$(ARCH)
LDFLAGS	:=	$(ARCH) -g -nostartfiles -Wl,--nmagic -Wl,-Map,$(TARGET).map -T hyperscan.ld

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).elf: crt0.o main.o
	$(CC) $(LDFLAGS) $^ -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
%.o: %.s
	$(CC) -x assembler-with-cpp $(ASFLAGS) -c $< -o $@


clean:
	rm -fr *.elf *.o *.bin *.map
