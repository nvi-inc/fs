#
# Makefile for TACD logging system
#
all: ../tacdclient
#
CC= cc
OBJECT_C = ./tacdclient.o ./logtacd.o ./err_report.o
#
../tacdclient: $(OBJECT_C)
	$(CC) $(OBJECT_C) -o ../tacdclient
clean:
	rm -f *.o core
##
clobber: clean
	rm -f tacdclient

# end of make for TACD.


