LIBES = ../clib/clib.a
OBJECTS= get_rxgain_files.o ../incom/get_rxgain.o get_gain_par2.o
#
../bin/gndat: gndat.o $(OBJECTS)
	cc  -o ../bin/gndat gndat.o $(OBJECTS) $(LIBES) -lm
	strip ../bin/gndat

gndat:
	rm -f ../bin/gndat
	make
#
