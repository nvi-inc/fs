OBJECTS = chekr.o bbc_brk.o bbchk.o dist_brk.o distchk.o\
err_rep.o getfm.o getif.o gettp.o getvc.o\
hdchk.o mk3drive.o mk3rack.o rec_brk.o recchk.o\
rxchk.o vform_brk.o vformchk.o vlbadrive.o vlbarack.o timechk.o
#
F77= gf77
#FFLAGS = -c -g -i2
FFLAGS = -c -g
LIBES = ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a \
../clib/clib.a ../lnfch/lnfch.a ../rtelb/rtelb.a -lrtx
#
../bin/chekr: $(OBJECTS)
	gf77 -g -o ../bin/chekr $(OBJECTS) $(LIBES)
	../setb/setb ../bin/chekr
#
chekr:
	rm -f ../bin/chekr
	make
