OBJECTS = setcl.o fc_stime.o
#
F77= gf77
FFLAGS = -c -g
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a\
../clib/clib.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a -lrtx
#
../bin/setcl: $(OBJECTS)
	gf77 -g -o ../bin/setcl $(OBJECTS) $(LIBES)
	../setb/setb ../bin/setcl
#
setcl:
	rm -f ../bin/setcl
	make
