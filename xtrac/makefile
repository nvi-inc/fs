#
OBJECTS = xtrac.o deerr.o defit.o defiv.o deoff.o deorg.o\
depnt.o depr.o desit.o desor.o detr.o detsy.o getdp.o\
gnext.o incsm.o inism.o kgetp.o kinit.o kobot.o kpout.o\
rstat.o tpstb.o kpout_ch.o
#
FFLAGS = -c 
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a
#
../bin/xtrac: $(OBJECTS)
	$(FC)  -o ../bin/xtrac $(OBJECTS) $(LIBES)
	strip ../bin/xtrac
#
xtrac:
	rm -f ../bin/xtrac
	make
