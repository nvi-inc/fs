#
OBJECTS = sigma.o kgdat.o kglin.o kgpnt.o \
kgsta.o kinit.o kpdat.o kpout.o unget.o
#
FFLAGS = -c 
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a \
../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/sigma: $(OBJECTS)
	$(FC)  -o ../bin/sigma $(OBJECTS) $(LIBES)
	strip ../bin/sigma
#
sigma:
	rm -f ../bin/sigma
	make
