OBJECTS = moon.o gd2xy.o moonp.o papvl.o
LIBS = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../flib/flib.a\
../lnfch/lnfch.a ../newlb/newlb.a ../fclib/fclib.a ../clib/clib.a \
../rtelb/rtelb.a

LDLIBS += $(FLIBS)
../bin/moon: $(OBJECTS) $(LIBS)

include ../include.mk
