OBJECTS = matcn.o datat.o echoe.o iat.o
#
F77= gf77
#FFLAGS = -c -g -i2
FFLAGS = -c -g
LIBES = ../port/port.a ../fslb/fslb.a ../newlb/newlb.a  \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../lnfch/lnfch.a\
../rtelb/rtelb.a -lrtx
#
../bin/matcn: $(OBJECTS)
	gf77 -g -o ../bin/matcn $(OBJECTS) $(LIBES)
	../setb/setb ../bin/matcn
#
matcn:
	rm -f ../bin/matcn
	make
