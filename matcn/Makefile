OBJECTS = matcn.o datat.o echoe.o iat.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES = ../port/port.a ../fslb/fslb.a ../lnfch/lnfch.a  \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../newlb/newlb.a\
../rtelb/rtelb.a
#
../bin/matcn: $(OBJECTS)
	$(FC)  -o ../bin/matcn $(OBJECTS) $(LIBES)
	strip ../bin/matcn
#
matcn:
	rm -f ../bin/matcn
	make
