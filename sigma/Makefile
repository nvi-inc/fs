OBJECTS = sigma.o kgdat.o kglin.o kgpnt.o \
kgsta.o kinit.o kpdat.o kpout.o unget.o

LIBS = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a \
../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a

LDLIBS += $(FLIBS)

../bin/sigma: $(OBJECTS) $(LIBS)

include ../include.mk
