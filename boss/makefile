#
all: ../bin/boss boss.a ../bin/helpsh
#
F77= gf77
FFLAGS = -c -g
LIBES = boss.a ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a\
../rtelb/rtelb.a -lrtx
#
OBJECTSL=\
gtnam.o gttim.o kpast.o krcur.o kstak.o newlg.o prget.o prpop.o prput.o\
readg.o readp.o reads.o reftm.o tmlis.o twrap.o
#
boss.a: $(OBJECTSL)
	touch boss.a
	rm boss.a
	ar qc boss.a $(OBJECTSL)
#
OBJECTS = boss.o binit.o bwork.o cants.o helpstr.o fshelp.o\
getcm.o getts.o lists.o newpf.o newpr.o \
newsk.o opnpf.o putts.o rdtib.o rdtma.o \
spars.o stat.o
#
../bin/boss: $(OBJECTS) boss.a
	gf77 -g -o ../bin/boss $(OBJECTS) $(LIBES)
	../setb/setb ../bin/boss
#
../bin/helpsh: helpsh
	cp helpsh ../bin/helpsh
	../setb/setb ../bin/helpsh

boss:
	rm -f ../bin/boss
	make
