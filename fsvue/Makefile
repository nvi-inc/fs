# Field System VLBI User Evironment fsVUE
# initial rdg
#
all: ../bin/vueinfo ../bin/fsvue
#
LIBES = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a ../newlb/newlb.a -lm
OBJECTS = \
vueinfo.o what_help.o
#
../bin/fsvue: ../fsvue/fsvue_start
	rm -f ../bin/fsvue
	ln -s ../fsvue/fsvue_start ../bin/fsvue
#
../bin/vueinfo: $(OBJECTS)
	$(CC)  -o ../bin/vueinfo $(OBJECTS) $(LIBES)
	strip ../bin/vueinfo
#
vueinfo:
	rm -f ../bin/vueinfo
	make

