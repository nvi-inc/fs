#
LIBS = 
OBJECTS = chk_time.o
#
../bin/chk_time: chk_time.o $(OBJECTS)
	gcc -o ../bin/chk_time $(OBJECTS) $(LIBS)
	strip ../bin/chk_time
#
chk_time:
	rm -f ../bin/chk_time
	make
