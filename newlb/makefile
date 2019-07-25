#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
char2low.o fmpread.o f_readstring.o f_rewind.o f_writestrng.o\
fclose.o fopen.o ftn_purge.o lower.o prog.o trimlen.o ymday.o\
iday0.o rcpar.o pname.o crcc.o igetb.o putb.o\
bitest.o bjtest.o iibset.o jibset.o iibclr.o jibclr.o iishftc.o\
jibits.o jmvbits.o iishft.o jishft.o
#
#CFLAGS = 
F77 = gf77
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
newlb.a: $(OBJECTS)
	touch newlb.a
	rm newlb.a
	ar -qc newlb.a $(OBJECTS)
	ar s newlb.a
