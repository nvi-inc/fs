OBJECTS = labck.o
#
F77= gf77
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a
#
../bin/labck: $(OBJECTS)
	gf77 -g -o ../bin/labck $(OBJECTS) $(LIBES)
	../setb/setb ../bin/labck
