OBJECTS = labck.o
#
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a
#
../bin/labck: $(OBJECTS)
	f77  -o ../bin/labck $(OBJECTS) $(LIBES)
	strip ../bin/labck
#
labck:
	rm -f ../bin/labck
	make
