#
OBJECTS = sigma.o kgdat.o kglin.o kgpnt.o \
kgsta.o kinit.o kpdat.o kpout.o unget.o
#
F77= gf77
FFLAGS = -c -g
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../newlb/newlb.a \
../lnfch/lnfch.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a -lrtx
#
../bin/sigma: $(OBJECTS)
	gf77 -g -o ../bin/sigma $(OBJECTS) $(LIBES)
	../setb/setb ../bin/sigma
#
sigma:
	rm -f ../bin/sigma
	make
