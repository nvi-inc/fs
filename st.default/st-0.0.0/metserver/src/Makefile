#
# Makefile for MET system
#
all: ../metserver diag
#
CC= cc
CFLAGS += -g
LIBES = ../port/port.a
OBJECT_S = ./metserver.o ./metget.o ./err_report.o ./nmea_wind.o
#
../metserver: $(OBJECT_S)
	$(CC) $(CFLAGS) $(OBJECT_S) $(LIBES) -o ../metserver -lpthread -lrt
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

