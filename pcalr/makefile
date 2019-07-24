OBJECTS = pcalr.o bpset.o bsplt.o dbcom.o dprox.o \
dump.o messg.o modet.o nrmlz.o pcalx.o pccor.o tpset.o\
i1bit.o sqish.o tabgn.o
#
#FFLAGS = -c -g -i2
F77= gf77
FFLAGS = -c -g
LIBES =  ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a\
../fclib/fclib.a ../clib/clib.a ../port/port.a ../fmpsee/fmpsee.a\
../rtelb/rtelb.a
#
../bin/pcalr: $(OBJECTS)
	gf77 -g -o ../bin/pcalr $(OBJECTS) $(LIBES) -lrtx
	../setb/setb ../bin/pcalr
#
pcalr:
	rm -f ../bin/pcalr
	make
