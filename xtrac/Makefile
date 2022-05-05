OBJECTS = xtrac.o deerr.o defit.o defiv.o deoff.o deorg.o\
depnt.o depr.o desit.o desor.o detr.o detsy.o getdp.o\
gnext.o incsm.o inism.o kgetp.o kinit.o kobot.o kpout.o\
rstat.o tpstb.o kpout_ch.o

LIBS = ../port/port.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a \
../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a


LDLIBS += $(FLIBS)

../bin/xtrac: $(OBJECTS) $(LIBS)

include ../include.mk
