#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
portopen.o portread.o portwrite.o portbaud.o portflush.o portoutdrain.o\
portdelay.o
#
#CFLAGS =
#FFLAGS = 
#
ifeq (/usr/src/linux/drivers/char/digi.h,\
$(wildcard /usr/src/linux/drivers/char/digi.h ))
CFLAGS := $(CFLAGS) -DDIGI
endif
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
port.a: $(OBJECTS)
	touch port.a
	rm port.a
	ar -qc port.a $(OBJECTS)
	ar s port.a
