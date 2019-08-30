OBJECTS = fivpt.o antcn.o dpoin.o errot.o fgaus.o fit2.o \
fitot.o fivp.o gooff.o jr2as.o local.o matcn.o matin.o \
offco.o offot.o onsor.o orign.o prfot.o reoff.o scmds.o \
site.o sorce.o tsys.o unslp.o volts.o wtsys.o mcbcn.o xoffot.o \
dscon.o dbbcn.o rdbcn.o dbbc3n.o r2dbcn.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
LIBES = ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a \
../port/port.a ../rtelb/rtelb.a
#
../bin/fivpt: $(OBJECTS)
	$(FC)  -o ../bin/fivpt $(OBJECTS) $(LIBES)
	strip ../bin/fivpt
#
fivpt:
	rm -f ../bin/fivpt
	make
