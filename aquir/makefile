#
OBJECTS = aquir.o antcn.o delne.o demas.o \
depar.o kgetc.o kinit.o knup.o onsor.o \
scmd.o sctl.o ssrc.o
#
F77= gf77
FFLAGS = -c -g
LIBES = ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a\
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a\
../rtelb/rtelb.a -lrtx
#
../bin/aquir: $(OBJECTS)
	gf77 -g -o ../bin/aquir $(OBJECTS) $(LIBES)
	../setb/setb ../bin/aquir
#
