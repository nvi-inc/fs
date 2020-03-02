# Makefile for lnfch for linux
#
ifdef FS_VERSION
ifeq ($(FC),f77)
FC=f95
endif
ARCHIV=ar -sqc
ifeq ($(FC),fort77)
FFLAGS= -c
CFLAGS= -c -DF2C
else
FFLAGS=-fno-range-check -fno-underscoring -g -D READ_LINE -finit-local-zero -fno-automatic -fbackslash
ifeq ($(shell uname -m),x86_64)
FFLAGS+=-fdefault-integer-8 -finteger-4-integer-8
endif
endif
endif
#
ARC = skdrlnfch.a
#
OBJECTS=\
pchar-linux.o jchar-linux.o char2hol.o hol2char.o cjchar.o \
ib2as.o ias2b.o ir2as.o das2b_new.o  \
ichmv.o ichmv_ch.o ichcm_ch.o  ichcm.o ifill.o ifill_ch.o  \
gtfld.o  gtrsp.o iflch.o mcoma.o iscnc.o iscns.o iscn_ch.o

#FC:=$(FORT)
#CC:=$(CC)

$(ARC): $(OBJECTS)
	touch $(ARC)
	rm $(ARC)
	$(ARCHIV) $(ARC) $(OBJECTS)

