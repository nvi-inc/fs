LIBS = ../clib/clib.a
OBJECTS = gndat.o get_rxgain_files.o get_gain_par2.o
LDLIBS += -lm

all: ../bin/gndat ../bin/gndat2

../bin/gndat: $(OBJECTS) $(LIBS)

../bin/gndat2:
	ln -sfn ../bin/gndat ../bin/gndat2

include ../include.mk
