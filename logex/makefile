OBJECTS= logex.o igtcm.o lxcfl.o fmpreadxx.o fmpwritexx.o\
lxcmd.o lxcom.o lxcrt.o lxget.o lxhlp.o\
lxhms.o lxist.o lxmcm.o lxopn.o lxout.o lxplt.o\
lxprc.o lxprm.o lxscl.o lxscm.o lxskd.o\
lxsum.o lxsze.o lxtim.o lxtyp.o lxwrt.o readl.o\
readt.o redsk.o unpsk.o writestr.o
#
FFLAGS = -c 
#
LIBES = ../bosslb/bosslb.a ../fslb/fslb.a ../polb/polb.a ../lnfch/lnfch.a\
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../fmpsee/fmpsee.a \
../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
#
../bin/logex: logex.o $(OBJECTS)
	$(FC)  -o ../bin/logex $(OBJECTS) $(LIBES)
	strip ../bin/logex
logex:
	rm -f ../bin/logex
	make
