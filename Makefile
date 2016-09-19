.PHONY: all

all: example/bin/test_suite.sms

###
# SMSSpec
###
SMSSPEC_SRC := $(shell (\
	find src -type f -name *constants.asm;\
	echo src/main.asm;\
	find src -type f -name *.asm\
) | awk '!x[$$0]++')

SMSSPEC_DST := dist/smsspec.asm

dist/smsspec.asm: $(SMSSPEC_SRC)
	@echo
	@echo "Collating $(SMSSPEC_DST)..."

	@echo "" > $(SMSSPEC_DST)
	@echo \;============================================================== >> $(SMSSPEC_DST) ;\
	echo \; SMSSpec >> $(SMSSPEC_DST) ;\
	echo \;============================================================== >> $(SMSSPEC_DST) ;\
	echo "" >> $(SMSSPEC_DST) ;\

	@for file in $(SMSSPEC_SRC) ; do \
		echo \;============================================================== >> $(SMSSPEC_DST) ;\
		echo \; $$(echo $$file | cut -c 5-) >> $(SMSSPEC_DST) ;\
		echo \;============================================================== >> $(SMSSPEC_DST) ;\
		echo >> $(SMSSPEC_DST) ;\
		cat $$file >> $(SMSSPEC_DST) ;\
		echo >> $(SMSSPEC_DST) ;\
	done

###
# Example
###
EXAMPLE_SRC := $(shell (find example -type f -name *.asm))
LINKFILE := example/build/linkfile

example/bin/test_suite.sms: example/build/linkfile example/build/test_suite.o
	@echo "Compiling example test suite..."
	@echo

	@cd example/build;\
	wlalink -dvrs linkfile ../bin/test_suite.sms;\
	mv .sym ../bin/test_suite.sym

example/build/linkfile:
	echo "[objects]" > $(LINKFILE)
	echo "test_suite.o" >> $(LINKFILE)

example/build/test_suite.o: dist/smsspec.asm $(EXAMPLE_SRC)
	@cd example;\
	wla-z80 -o test_suite.asm ./build/test_suite.o;
