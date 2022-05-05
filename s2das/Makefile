#
# Makefile for S2 library routines
#
# Field system information
FSDIR = ..
FSINC = $(FSDIR)/include

S2DIR = $(FSDIR)/s2das
S2INC = $(S2DIR)

DEST  = ./s2das.a

#include flags
INCFLG = -I$(FSINC) -I$(S2INC)

# Flags
FFLAGS = -c
CFLAGS = -g $(INCFLG)

# Objects
OBJECTS = quik_util.o rcl_das.o stats.o s2das_util.o message.o

#
$(DEST): $(OBJECTS)
	touch $(DEST)
	rm $(DEST)
	ar -qc $(DEST) $(OBJECTS)
	ar -s $(DEST)
clean:
	rm -f *.o
#
