#
OBJECTS = resid.o kglin.o kgpnt.o kinit.o \
kpout.o pbrdr.o pfrme.o po2pl.o pp2ch.o pplot.o \
pplpt.o pppnt.o ppstr.o pquik.o pscal.o pseto.o \
psetp.o psetr.o psetv.o pv2ob.o pwipe.o unget.o
#
FFLAGS = -c 
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a
#
../bin/resid: $(OBJECTS)
	f77  -o ../bin/resid $(OBJECTS) $(LIBES)
	strip ../bin/resid
#
resid:
	rm -f ../bin/resid
	make
#
