#
LIBES =  ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
OBJECTS = antcn.o pname.o logit.o
#
../bin/antcn: $(OBJECTS)
	cc -g -o ../bin/antcn $(OBJECTS) $(LIBES)
	../../fs/setb/setb ../bin/antcn
#
antcn:
	rm -f ../bin/antcn
	make
