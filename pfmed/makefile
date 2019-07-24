OBJECTS = \
pfmed.o fed.o ffm.o ffmp.o fnblnk.o kerr.o pfblk.o \
pfcop.o pfmbd.o purn.o reprc.o ftn_edit.o
F77= gf77
FFLAGS = -c -g
LIBES = ../newlb/newlb.a ../fslb/fslb.a ../lnfch/lnfch.a ../flib/flib.a\
 ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
../bin/pfmed: $(OBJECTS)
	gf77 -g -o ../bin/pfmed $(OBJECTS) $(LIBES)
	../setb/setb ../bin/pfmed
#
pfmed:
	rm -f ../bin/pfmed
	make
