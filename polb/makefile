#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
cnvrt.o datan2z.o equn.o fln.o flt0.o gmodl.o\
gtchr.o gtdbl.o gtdc.o gtra.o gtrel.o igeta.o\
igtbn.o iptdc.o iptra.o jr2as.o kcrt.o keof.o\
kfild.o kfmp.o kgant.o kidnam.o kif.o kopn.o\
koutp.o kpant.o kread.o kreof.o kwrit.o refr.o\
sider.o po_put_i.o po_put_c.o fmpwrite2.o sider2.o equn2.o gtdbl.o jd2as.o
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
polb.a: $(OBJECTS)
	touch polb.a
	rm polb.a
	ar -qc polb.a $(OBJECTS)
	ar s polb.a
