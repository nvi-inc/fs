#
CFLAGS= -g
LIBES = ../stlib/stlib.a ../../fs/clib/clib.a ../../fs/rtelb/rtelb.a
#
OBJECTS =\
stqkr.o 
#
../bin/stqkr: $(OBJECTS)
	cc -g -o ../bin/stqkr $(OBJECTS) $(LIBES) -lm
	strip ../bin/stqkr
#
stqkr:
	rm -f ../bin/stqkr
	make
