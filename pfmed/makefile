OBJECTS = \
pfmed.o fed.o ffm.o ffmp.o fnblnk.o kerr.o pfblk.o \
pfcop.o pfmbd.o purn.o reprc.o ftn_edit.o
#
FFLAGS = -c 
LIBES = ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a\
 ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/pfmed: $(OBJECTS)
	f77  -o ../bin/pfmed $(OBJECTS) $(LIBES)
	strip ../bin/pfmed
#
pfmed:
	rm -f ../bin/pfmed
	make
