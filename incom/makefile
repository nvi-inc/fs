#
ifndef VERSION
VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 0
endif
#
OBJECTS = incom.o sincom.o
#
FFLAGS = -cpp -DVERSION=$(VERSION) -DSUBLEVEL=$(SUBLEVEL) -DPATCHLEVEL=$(PATCHLEVEL)
LIBES = ../bosslb/bosslb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a\
../rtelb/rtelb.a
#
../bin/incom: $(OBJECTS)
	$(FC)  -o ../bin/incom $(OBJECTS) $(LIBES)
	strip ../bin/incom
incom:
	rm -f ../bin/incom
	make
