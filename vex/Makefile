#
YACC=bison
YFLAGS=-d -y
LEX=flex
OBJECTS=vex.o vexf.o vex.yy.o vex_util.o print_vex.o vex_get.o
CC=gcc
#
# F2C needs this others don't
CFLAGS=-DF2C
#

vex.a: $(OBJECTS)
	touch $@
	rm $@
	ar -qc $@ $(OBJECTS)
#
# GNU ar (Linux) needs this, others don't
	ar s $@
#
	rm -f vex.c vex.yy.c

vex.yy.o:	vex.yy.l y.tab.h

y.tab.h:	vex.y

vex_util.o:	y.tab.h

print_vex.o:	y.tab.h

vex_get.o:	y.tab.h

vexf.o:		y.tab.h
