#
OBJECTS = error.o dppco.o dppfa.o dppin.o dppsl.o fecon.o \
fit2.o incne.o incsm.o inine.o inism.o kgetm.o kglin.o kgpnt.o \
kinit.o kpcon.o kpdat.o kpfit.o kplin.o kpout.o kpst.o kptri.o \
rstat.o scaler.o unget.o unscaler.o
#
F77= gf77
FFLAGS = -c -g
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a -lrtx
#
../bin/error: $(OBJECTS)
	gf77 -g -o ../bin/error $(OBJECTS) $(LIBES)
	../setb/setb ../bin/error
#
error:
	rm -f ../bin/error
	make
