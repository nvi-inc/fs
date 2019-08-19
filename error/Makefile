OBJECTS = error.o dppco.o dppfa.o dppin.o dppsl.o fecon.o \
fit2.o incne.o incsm.o inine.o inism.o kgetm.o kglin.o kgpnt.o \
kinit.o kpcon.o kpdat.o kpfit.o kplin.o kpout.o kpst.o kptri.o \
rstat.o scaler.o unget.o unscaler.o kpout_ch.o kpdat2.o apost.o indx.o

LIBS = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a \
../poclb/poclb.a ../vis/vis.a ../rtelb/rtelb.a ../clib/clib.a

LDLIBS += $(FLIBS)

../bin/error: $(OBJECTS) $(LIBS)

include ../include.mk
