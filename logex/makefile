OBJECTS= logex.o igtcm.o lxcfl.o fmpreadxx.o fmpwritexx.o\
lxcmd.o lxcom.o lxcrt.o lxget.o lxhlp.o\
lxhms.o lxist.o lxmcm.o lxopn.o lxout.o lxplt.o\
lxprc.o lxprm.o lxscl.o lxscm.o lxskd.o\
lxsum.o lxsze.o lxtim.o lxtyp.o lxwrt.o readl.o\
readt.o redsk.o unpsk.o fmpwriteyy.o fmpreadyy.o\
writestr.o
#
F77 = gf77
#
FFLAGS = -c -g
#
LIBES = ../boss/boss.a ../fslb/fslb.a ../newlb/newlb.a ../polb/polb.a\
../lnfch/lnfch.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../fmpsee/fmpsee.a ../vis/vis.a ../rtelb/rtelb.a -lrtx
#
../bin/logex: logex.o $(OBJECTS)
	gf77 -g -o ../bin/logex $(OBJECTS) $(LIBES)
	../setb/setb ../bin/logex
logex:
	rm -f ../bin/logex
	make
