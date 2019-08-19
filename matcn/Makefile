OBJECTS = matcn.o datat.o echoe.o iat.o
LIBS = ../port/port.a ../fslb/fslb.a ../lnfch/lnfch.a  \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../newlb/newlb.a\
../rtelb/rtelb.a

LDLIBS += $(FLIBS)

../bin/matcn: $(OBJECTS) $(LIBS)

include ../include.mk
