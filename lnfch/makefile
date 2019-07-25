#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
char2hol.o cjchar.o das2b.o fdfld.o gbfas.o gtfld.o gtprm.o\
gtrsp.o hol2char.o ia22h.o ia2hx.o ias2b.o ib2as.o\
ibin.o ichcm.o ichcm_ch.o ichmv.o ifams.o ifill.o ifill_ch.o iflch.o\
ih22a.o ihx2a.o ir2as.o iscn_ch.o iscnc.o iscns.o\
jchar.o mcoma.o pchar.o reio.o gtprm2.o ichmv_ch.o
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
lnfch.a: $(OBJECTS)
	touch lnfch.a
	rm lnfch.a
	ar -qc lnfch.a $(OBJECTS)
	ar s lnfch.a
