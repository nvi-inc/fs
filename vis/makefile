#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
dvdot.o dvmpy.o dvnrm.o dvpiv.o dvsmy.o
#
#CFLAGS = 
#FFLAGS = 
F77 = gf77
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
vis.a: $(OBJECTS)
	touch vis.a
	rm vis.a
	ar -qc vis.a $(OBJECTS)
	ar s vis.a
