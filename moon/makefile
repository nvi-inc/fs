OBJECTS = moon.o gd2xy.o moonp.o papvl.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../flib/flib.a\
../lnfch/lnfch.a ../newlb/newlb.a ../fclib/fclib.a ../clib/clib.a \
../rtelb/rtelb.a
#
../bin/moon: $(OBJECTS)
	$(FC)  -o ../bin/moon $(OBJECTS) $(LIBES)
	strip ../bin/moon
