OBJECTS = labck.o
#
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a
#
../bin/labck: $(OBJECTS)
	$(FC)  -o ../bin/labck $(OBJECTS) $(LIBES)
	strip ../bin/labck
#
labck:
	rm -f ../bin/labck
	make
