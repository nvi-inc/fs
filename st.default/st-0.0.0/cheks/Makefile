#
CFLAGS= -g
#
LIBS = -lm ../../fs/poclb/poclb.a ../../fs/clib/clib.a\
../../fs/rtelb/rtelb.a -lm
#
OBJECTS = cheks.o
#
../bin/cheks : $(OBJECTS)
	cc -g -o ../bin/cheks $(OBJECTS) $(LIBS) -lm
	strip ../bin/cheks
#
cheks : 
	rm -f ../bin/cheks
	make
