OBJECTS = setcl.o
#
FFLAGS = -c 
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a\
../clib/clib.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a
#
../bin/setcl: $(OBJECTS)
	$(FC)  -o ../bin/setcl $(OBJECTS) $(LIBES)
	strip ../bin/setcl
#
setcl:
	rm -f ../bin/setcl
	make
