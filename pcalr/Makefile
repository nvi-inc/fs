OBJECTS = pcalr.o bpset.o bsplt.o dbcom.o dprox.o \
dump.o messg.o modet.o nrmlz.o pcalx.o pccor.o tpset.o\
i1bit.o sqish.o tabgn.o

LIBS =  ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a\
../fclib/fclib.a ../port/port.a ../fmpsee/fmpsee.a ../poclb/poclb.a \
../clib/clib.a ../rtelb/rtelb.a

LDLIBS += $(FLIBS)

../bin/pcalr: $(OBJECTS) $(LIBS)

include ../include.mk
