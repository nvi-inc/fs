#
# Linux Makefile for RCL interface library, compiler: GNU C compiler.
# Tested under Linux 1.2.12.
# Note that all source and header files should be checked to ensure 
# the lines don't contain ^M (cntl-M) at the end as in DOS.
#

SRCS= rcl_cmd.c rcl_pkt.c rcl_sysn.c rcl_util.c
OBJS= $(SRCS:.c=.o)

CC= gcc
CFLAGS= -O -g -Wall -DUNIX -DLINUX
CPPFLAGS=

.c.o:
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $*.c


.PHONY: all
all: $(OBJS)

# rule to build "mini" test program
test: $(OBJS) test.o
	$(CC) -o test $(OBJS) test.o

depend: force
	makedepend -- $(CPPFLAGS) $(CFLAGS) -- $(SRCS) test.c

# dummy target to force execution of a rule (do not create a file of this name)
force:


# DO NOT DELETE THIS LINE -- make depend depends on it.

rcl_cmd.o: rcl_def.h rcl.h
rcl_cmd.o: ext_ircl.h rcl_pkt.h rcl_cmd.h
rcl_pkt.o: rcl_def.h rcl.h ext_ircl.h rcl_sys.h rcl_pkt.h
rcl_sysn.o: rcl_def.h rcl.h
rcl_sysn.o: ext_ircl.h rcl_sys.h
rcl_util.o: rcl_def.h rcl.h
rcl_util.o: ext_ircl.h rcl_util.h
test.o: rcl.h rcl_def.h ext_ircl.h rcl_cmd.h
test.o: rcl_pkt.h rcl_sys.h
