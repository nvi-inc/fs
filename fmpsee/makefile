#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
fmpappend.o fmpclose.o fmpopen.o fmpposition.o fmppost.o fmppurge.o\
fmpreadstr.o fmprewind.o fmpsetline.o fmpsetpos.o fmpwritestr.o
#
#CFLAGS = 
#FFLAGS = 
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
fmpsee.a: $(OBJECTS)
	touch fmpsee.a
	rm fmpsee.a
	ar -qc fmpsee.a $(OBJECTS)
	ar s fmpsee.a
