OBJECTS = chekr.o bbc_brk.o bbchk.o dist_brk.o distchk.o\
err_rep.o getfm.o getif.o gettp.o getvc.o\
hdchk.o mk3drive.o mk3rack.o rec_brk.o recchk.o\
rxchk.o vform_brk.o vformchk.o vlbadrive.o vlbarack.o timechk.o i3chk.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES = ../fslb/fslb.a ../lnfch/lnfch.a ../flib/flib.a ../fclib/fclib.a \
../clib/clib.a ../newlb/newlb.a ../rtelb/rtelb.a
#
../bin/chekr: $(OBJECTS)
	f77  -o ../bin/chekr $(OBJECTS) $(LIBES)
	strip ../bin/chekr
#
chekr:
	rm -f ../bin/chekr
	make
