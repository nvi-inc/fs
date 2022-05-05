OBJECTS = holog.o jr2as.o savoff.o antcn.o onsor.o scmds.o gooff.o local.o\
next.o scmd.o
LIBS = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a

../bin/holog: $(OBJECTS) $(LIBS)

LDLIBS += -lm

include ../include.mk
