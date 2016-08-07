#
CFLAGS= 
LIBES = ../poclb/poclb.a ../clib/clib.a ../poclb/poclb.a ../rtelb/rtelb.a -lm
#
OBJECTS = rdtcn.o FFT.o rdbe_freqz.o rt_nonfinite.o rtGetInf.o rtGetNaN.o
#
../bin/rdtcn: $(OBJECTS)
	cc  -o ../bin/rdtcn $(OBJECTS) $(LIBES)
	strip ../bin/rdtcn
#
rdtcn:
	rm -f ../bin/rdtcn
	make
