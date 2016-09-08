#
ifndef VERSION
VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 0
endif
#
OBJECTS = incom.o sincom.o equip.o drivem.o drivev.o head.o driveall.o\
get_rxgain_files.o get_flux.o\
get_flux_file.o
#
FFLAGS = -cpp -DVERSION=$(VERSION) -DSUBLEVEL=$(SUBLEVEL) -DPATCHLEVEL=$(PATCHLEVEL)
LIBES = ../bosslb/bosslb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a ../poclb/poclb.a \
../clib/clib.a ../rtelb/rtelb.a
#
../bin/incom: $(OBJECTS)
	$(FC)  -o ../bin/incom $(OBJECTS) $(LIBES)
	strip ../bin/incom
incom:
	rm -f ../bin/incom
	make
