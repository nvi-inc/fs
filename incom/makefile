OBJECTS = incom.o sincom.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES = ../bosslb/bosslb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a\
../rtelb/rtelb.a
#
../bin/incom: $(OBJECTS)
	f77  -o ../bin/incom $(OBJECTS) $(LIBES)
	strip ../bin/incom
incom:
	rm -f ../bin/incom
	make
