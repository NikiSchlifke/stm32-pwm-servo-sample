##
# Toplevel Makefile PWM 
#
# Stefan Wendler, sw@kaltpost.de 
##

BASEDIR 		= .
SRCDIR  		= src
DEPLOYDIR		= deploy
TMPDIR		= /tmp
VERSION		= 0.1
TARGET		= PWMSample_v$(VERSION)

all: target

world: target gen-docs

target: 
	make -C $(SRCDIR)

gen-docs: target
	cd $(SRCDIR) && make gen-docs 

style:
	cd $(SRCDIR) && make style

check: 
	make -C $(SRCDIR) check

deploy-src: target check style clean gen-docs
	rm -fr $(TMPDIR)/$(TARGET)_src
	mkdir $(TMPDIR)/$(TARGET)_src
	cp -a ./* $(TMPDIR)/$(TARGET)_src/.
	rm -fr $(TMPDIR)/$(TARGET)_src/deploy
	rm -fr $(TMPDIR)/$(TARGET)_src/tools
	mkdir $(TMPDIR)/$(TARGET)_src/deploy
	(cd $(TMPDIR); tar --exclude=".svn" -jcvf $(TARGET)_src.tar.bz2  $(TARGET)_src)
	mv $(TMPDIR)/$(TARGET)_src.tar.bz2 $(DEPLOYDIR)/. 

deploy-bin: clean target 
	rm -fr $(TMPDIR)/$(TARGET)_bin
	mkdir $(TMPDIR)/$(TARGET)_bin
	cp CHANGELOG LICENSE README $(TMPDIR)/$(TARGET)_bin/.
	cp -a ./bin $(TMPDIR)/$(TARGET)_bin/.
	cp -a ./doc $(TMPDIR)/$(TARGET)_bin/.
	(cd $(TMPDIR); tar --exclude=".svn" -jcvf $(TARGET)_bin.tar.bz2  $(TARGET)_bin)
	mv $(TMPDIR)/$(TARGET)_bin.tar.bz2 $(DEPLOYDIR)/. 
	
deploy: deploy-src deploy-bin

flash-target: target
	openocd -f interface/openocd-usb.cfg -f board/olimex_stm32_h103.cfg \
		-c init -c targets -c "halt" -c "flash write_image erase ./bin/firmware.elf" \
		-c "verify_image ./bin/firmware.elf" \
		-c "reset run" -c shutdown
clean: 
	make -C $(SRCDIR) clean
	rm -fr doc/gen	
	rm -f bin/*
