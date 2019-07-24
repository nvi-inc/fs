all: ../bin/monit1 ../bin/monit2 ../bin/monit3
#
F77= gf77
FFLAGS = -c
CFLAGS = -g
LIBES= -lcurses -ltermlib -lm ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
OBJECTS1 = monit1.o die.o
#
../bin/monit1: $(OBJECTS1)
	cc -o ../bin/monit1 $(OBJECTS1) $(LIBES)
	../setb/setb ../bin/monit1
#
OBJECTS2 = monit2.o die.o azel.o sider.o pre_str.o cnvrt.o
#
../bin/monit2: $(OBJECTS2)
	cc -o ../bin/monit2 $(OBJECTS2) $(LIBES)
	../setb/setb ../bin/monit2
#
OBJECTS3 = monit3.o die.o pre_str.o
#
../bin/monit3: $(OBJECTS3)
	cc -o ../bin/monit3 $(OBJECTS3) $(LIBES)
	../setb/setb ../bin/monit3
