#
# Makefile for MET system
#
all: ../metserver
#
CC= cc
LIBES = ../lib/port.a
OBJECT_S = ./metserver.o ./metget.o ./err_report.o
#
../metserver: $(OBJECT_S)
	$(CC) $(OBJECT_S) $(LIBES) -o ../metserver
#
clean:
	rm -f *.o core
##
clobber: clean
	rm -f metserver

# end of make for MET.


