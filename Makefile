# http://wiki.osdev.org/Makefile
# Implement pattern rules: http://stackoverflow.com/a/1633553

BUILD_DIR := build
LINKFILE := $(BUILD_DIR)/linkfile

SRCFILES := smsspec.asm
OBJFILES := $(patsubst %.asm,%.o,$(SRCFILES))

COMPILER := wla-z80
COMPILER_FLAGS := -o

.PHONY: all watch

all:
	rm -f smsspec.o
	$(COMPILER) $(COMPILER_FLAGS) smsspec.asm smsspec.o

	@echo [objects] > $(LINKFILE)
	@echo smsspec.o >> $(LINKFILE)

	@wlalink -drvs $(LINKFILE) bin/smsspec.sms
