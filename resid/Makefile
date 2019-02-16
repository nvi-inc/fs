OBJECTS = resid.o kglin.o kgpnt.o kinit.o \
kpout.o pbrdr.o pfrme.o po2pl.o pp2ch.o pplot.o \
pplpt.o pppnt.o ppstr.o pquik.o pscal.o pseto.o \
psetp.o psetr.o psetv.o pv2ob.o pwipe.o unget.o

LIBS = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a \
../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a

LDLIBS += $(FLIBS)

../bin/resid: $(OBJECTS) $(LIBS)

include ../include.mk
