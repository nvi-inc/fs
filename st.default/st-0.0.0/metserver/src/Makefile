#
# Makefile for MET system
#
all: ../metserver diag
#
CC= cc
LIBES = ../port/port.a
OBJECT_S = ./metserver.o ./metget.o ./err_report.o
#
../metserver: $(OBJECT_S)
	$(CC) $(OBJECT_S) $(LIBES) -o ../metserver -lpthread
#
diag: 
	$(MAKE) -f MakeDiag
#
clean:
	rm -f *.o core
##
clobber: clean
	rm -f ../metserver ../metwind

# end of make for MET.

