OBJECTS = headp.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES = ../fslb/fslb.a\
../lnfch/lnfch.a\
../newlb/newlb.a\
../flib/flib.a\
../fclib/fclib.a\
../clib/clib.a\
../fmpsee/fmpsee.a\
../rtelb/rtelb.a

#
../bin/headp: $(OBJECTS)
	$(FC)  -o ../bin/headp $(OBJECTS) $(LIBES)
	strip ../bin/headp
