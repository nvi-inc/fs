#
# Linux Makefile for rclco program, compiler: GNU C compiler.
# Tested under Linux 1.2.12.
# Note that all source and header files should be checked to ensure 
# the lines don't contain ^M (cntl-M) at the end as in DOS.
# Note: The "implicit declaration of function" warnings can be ignored.
# You may want to turn gcc's -Wall option off to reduce warning messages.
#

SRCS= main.c cmd.c input.c softkey.c lib.c printf.c version.c
OBJS= $(SRCS:.c=.o)

CC= gcc
CFLAGS= -g -Ircl -Wall -DUNIX -DLINUX
CPPFLAGS=

.c.o:
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $*.c


rclco: $(OBJS)
	$(CC) -o rclco $(OBJS) rcl/rcl_cmd.o rcl/rcl_pkt.o rcl/rcl_sysn.o rcl/rcl_util.o -lcurses

version.c: force
	./makever.unx >version.c

depend: force
	makedepend -- $(CPPFLAGS) $(CFLAGS) -- $(SRCS)

# dummy target to force execution of a rule (do not create a file of this name)
force:


# DO NOT DELETE THIS LINE -- make depend depends on it.

main.o: main.h ext_init.h
main.o: rcl/rcl_def.h rcl/rcl.h rcl/ext_ircl.h rcl/rcl_cmd.h rcl/rcl_pkt.h
main.o: rcl/rcl_sys.h lib.h cmd.h softkey.h input.h version.h
cmd.o: main.h ext_init.h
cmd.o: rcl/rcl_def.h rcl/rcl.h rcl/ext_ircl.h rcl/rcl_cmd.h rcl/rcl_sys.h
cmd.o: rcl/rcl_util.h lib.h softkey.h cmd.h input.h version.h
input.o: main.h ext_init.h lib.h rcl/rcl_sys.h input.h
input.o: softkey.h cmd.h
softkey.o: main.h ext_init.h lib.h softkey.h cmd.h
lib.o: main.h ext_init.h input.h softkey.h cmd.h lib.h
printf.o: main.h ext_init.h lib.h
version.o: version.h
