#
LIBS=../vex.a
OBJECTS1=w1.o
OBJECTS2=w2.o
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
#
#FFLAGS = -c 
#LIBES = ../port/port.a ../fslb/fslb.a ../lnfch/lnfch.a  \
#../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../newlb/newlb.a\
#../rtelb/rtelb.a
#
all: w1 w2
#
w1: $(OBJECTS1) $(LIBS)
	$(FC)  -o w1 $(OBJECTS1) $(LIBS) -lf2c -lfl
#
w2: $(OBJECTS2) $(LIBS)
	$(FC)  -o w2 $(OBJECTS2) $(LIBS) -lf2c -lfl
