#
OBJECTS = sigma.o kgdat.o kglin.o kgpnt.o \
kgsta.o kinit.o kpdat.o kpout.o unget.o
#
FFLAGS = -c 
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a
#
../bin/sigma: $(OBJECTS)
	$(FC)  -o ../bin/sigma $(OBJECTS) $(LIBES)
	strip ../bin/sigma
#
sigma:
	rm -f ../bin/sigma
	make
