OBJECTS = headp.o
LIBS = ../fslb/fslb.a\
../lnfch/lnfch.a\
../newlb/newlb.a\
../flib/flib.a\
../fclib/fclib.a\
../clib/clib.a\
../fmpsee/fmpsee.a\
../rtelb/rtelb.a

all: ../bin/headp ../bin/headp1 ../bin/headp2

LDLIBS += $(FLIBS)
../bin/headp: $(OBJECTS) $(LIBS)

../bin/headp1 ../bin/headp2:
	ln -s ../bin/headp $@

include ../include.mk
