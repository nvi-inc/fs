OBJECTS = onoff.o jr2as.o tpi_mark.o tpget_mark.o get_samples.o ini_accum.o\
inc_accum.o red_accum.o savoff.o antcn.o onsor.o scmds.o gooff.o local.o\
tzero.o matcn.o wcounts.o tpget_vlba.o agc.o tpget_lba.o agc_dbbc.o\
tpget_dbbc.o tpget_rdbe.o agc_dbbc3.o tpget_dbbc3.o

LIBS = ../clib/clib.a ../rtelb/rtelb.a ../poclb/poclb.a 
LDLIBS += -lm

../bin/onoff: $(OBJECTS) $(LIBS)

include ../include.mk
