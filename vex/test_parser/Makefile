#
LIBS=../vex.a -lfl
OBJECTS=main.o
CC=gcc

all: main t

main: $(OBJECTS)
	gcc -o v $(OBJECTS) $(LIBS)
t: t.o gfields.o
	$(FC) -o t t.o gfields.o -lf2c $(LIBS)
