OBJECTS = fserr.o direc.o find.o uptime.o
#
#FFLAGS = -c -g -i2
FFLAGS = -c
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../clib/clib.a ../rtelb/rtelb.a\
-lrtx
#
../bin/fserr: $(OBJECTS)
	cc -o ../bin/fserr $(OBJECTS) $(LIBES)
	../setb/setb ../bin/fserr
