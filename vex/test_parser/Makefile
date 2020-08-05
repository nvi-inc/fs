#
LIBS=../vex.a
OBJECTS=v.o
CC=gcc

ifeq ($(FC),f77)
  FC=f95
endif
ARCHIV=ar -sqc
ifeq ($(FC),fort77)
  FFLAGS= -c
  CFLAGS= -c -DF2C
else
  FFLAGS=-fno-range-check -fno-underscoring -g -D READ_LINE -finit-local-zero -fno-automatic -fbackslash
  ifeq ($(shell uname -m),x86_64)
    FFLAGS+=-fdefault-integer-8 -finteger-4-integer-8
  endif
endif


all: v t

v: $(OBJECTS) $(LIBS)
	gcc -o v $(OBJECTS) $(LIBS) -lfl
t: t.o gfields.o $(LIBS)
	$(FC) -o t t.o gfields.o -lf2c $(LIBS) -lfl
