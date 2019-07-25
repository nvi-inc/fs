OBJECTS = onoff.o antcn.o dpnt2.o gooff.o jr2as.o \
local.o matcn.o onof.o onsor.o orign.o reslt.o \
scmds.o site.o sorce.o tzer.o vlts2.o mcbcn2.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
#LIBES = ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a
LIBES = ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a \
../port/port.a ../rtelb/rtelb.a
#
../bin/onoff: $(OBJECTS)
	f77  -o ../bin/onoff $(OBJECTS) $(LIBES)
	strip ../bin/onoff
#
onoff:
	rm -f ../bin/onoff
	make
