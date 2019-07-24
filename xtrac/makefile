#
OBJECTS = xtrac.o deerr.o defit.o defiv.o deoff.o deorg.o\
depnt.o depr.o desit.o desor.o detr.o detsy.o getdp.o\
gnext.o incsm.o inism.o kgetp.o kinit.o kobot.o kpout.o\
rstat.o tpstb.o
#
F77= gf77
FFLAGS = -c -g
LIBES = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../newlb/newlb.a \
../lnfch/lnfch.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a -lrtx
#
../bin/xtrac: $(OBJECTS)
	gf77 -g -o ../bin/xtrac $(OBJECTS) $(LIBES)
	../setb/setb ../bin/xtrac
#
xtrac:
	rm -f ../bin/xtrac
	make
