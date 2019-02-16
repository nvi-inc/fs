OBJECTS = aquir.o antcn.o delne.o demas.o \
depar.o kgetc.o kinit.o knup.o onsor.o \
scmd.o sctl.o ssrc.o

LIBS = ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a ../poclb/poclb.a \
../clib/clib.a ../rtelb/rtelb.a

LDLIBS += $(FLIBS)
../bin/aquir: $(OBJECTS) $(LIBS)

include ../include.mk
