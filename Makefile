# http://wiki.osdev.org/Makefile
# Implement pattern rules: http://stackoverflow.com/a/1633553

BUILD_DIR := build
LINKFILE := $(BUILD_DIR)/linkfile

SRCFILES := test_suite.asm
OBJFILES := $(patsubst %.asm,%.o,$(SRCFILES))

COMPILER := wla-z80
COMPILER_FLAGS := -o

.PHONY: all watch

all:
	rm -f test_suite.o
	$(COMPILER) $(COMPILER_FLAGS) test_suite.asm test_suite.o

	@echo [objects] > $(LINKFILE)
	@echo test_suite.o >> $(LINKFILE)

	@wlalink -drvs $(LINKFILE) bin/test_suite.sms

tdd:
	while true; do make 1>/dev/null; sleep 3; done