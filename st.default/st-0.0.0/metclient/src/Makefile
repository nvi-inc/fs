#
# Makefile for MET system
#
all: ../metclient
#
CC= cc
OBJECT_C = ./metclient.o ./logwx.o ./err_report.o
#
../metclient: $(OBJECT_C)
	$(CC) $(OBJECT_C) -o ../metclient
clean:
	rm -f *.o core
##
clobber: clean
	rm -f metclient

# end of make for MET.


