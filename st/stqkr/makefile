#
CFLAGS= -g
LIBES = ../stlib/stlib.a ../../fs/clib/clib.a ../../fs/rtelb/rtelb.a -lrtx 
#
OBJECTS =\
stqkr.o 
#
../bin/stqkr: $(OBJECTS)
	cc -g -o ../bin/stqkr $(OBJECTS) $(LIBES) -lm
	../../fs/setb/setb ../bin/stqkr
#
stqkr:
	rm -f ../bin/stqkr
	make
