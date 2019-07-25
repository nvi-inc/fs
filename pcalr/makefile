OBJECTS = pcalr.o bpset.o bsplt.o dbcom.o dprox.o \
dump.o messg.o modet.o nrmlz.o pcalx.o pccor.o tpset.o\
i1bit.o sqish.o tabgn.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES =  ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a\
../fclib/fclib.a ../clib/clib.a ../port/port.a ../fmpsee/fmpsee.a\
../rtelb/rtelb.a
#
../bin/pcalr: $(OBJECTS)
	f77  -o ../bin/pcalr $(OBJECTS) $(LIBES)
	strip ../bin/pcalr
#
pcalr:
	rm -f ../bin/pcalr
	make
