OBJECTS = incom.o sincom.o
#
F77= gf77
#FFLAGS = -c -g -i2
FFLAGS = -c -g
LIBES = ../boss/boss.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a\
../rtelb/rtelb.a -lrtx
#
../bin/incom: $(OBJECTS)
	gf77 -g -o ../bin/incom $(OBJECTS) $(LIBES)
	../setb/setb ../bin/incom
incom:
	rm -f ../bin/incom
	make
