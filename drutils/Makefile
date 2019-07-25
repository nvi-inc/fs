#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
aposn.o axtyp.o backward.o cablw.o ckiau.o clear_array.o clndr.o\
cvpos.o flinp.o forward.o frinp.o gnpas.o hdinp.o hol2lower.o\
hol2upper.o idate.o iday0.o igtba.o igtfr.o igtso.o igtst.o igtst2.o\
in2a2.o inc.o ind.o initf.o julda.o kbit.o kcont.o kearl.o knaeq.o\
locf.o lower.o novas.o null_term.o pid_str.o posnt.o prefr.o printer.o\
raded.o ras2b.o rdctl.o readf_asc.o reads.o reio.o sbit.o secnds.o\
sidtm.o slewo.o slewt.o soinp.o speed.o stinp.o sunarc.o sunazel.o\
sunpo.o trimlen.o tspin.o unpco.o unpfl.o unpfr.o unphd.o unplo.o\
unpso.o unpva.o unpvb.o unpvh.o unpvl.o unpvp.o unpvt.o unpwc.o\
unpwo.o upper.o vbinp.o writf_asc.o writf_asc_ch.o xat.o\
ydjul.o ymday.o 
#
#CFLAGS = 
#FFLAGS = 
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name fclib before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
drutils.a: $(OBJECTS)
	touch drutils.a
	rm drutils.a
	ar -qc drutils.a $(OBJECTS)
	ar s drutils.a
