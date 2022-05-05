#
ifndef VERSION
VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 0
endif

FC1 := $(FC)

OBJECTS = incom.o sincom.o equip.o drivem.o drivev.o head.o driveall.o\
get_rxgain_files.o get_flux.o get_flux_file.o rdbe_equip.o crelease.o

crelease.o: CFLAGS += -DRELEASE=$(RELEASE) -DFC1=$(FC1)

LDLIBS += $(FLIBS)

sincom.o: FFLAGS += -cpp -DVERSION=$(VERSION) -DSUBLEVEL=$(SUBLEVEL) -DPATCHLEVEL=$(PATCHLEVEL)

LIBS = ../bosslb/bosslb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a ../poclb/poclb.a \
../clib/clib.a ../rtelb/rtelb.a

../bin/incom: $(OBJECTS) $(LIBS)

include ../include.mk
