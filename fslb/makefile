#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
ad2ma.o add_class.o bell.o chmov.o copin.o dtnam.o en2ma.o\
fblnk.o get_atod.o get_class.o iadt.o idoff.o if2ma.o ifmed.o\
ihash.o iifed.o ipgst.o isoed.o itped.o ivced.o\
julda.o kbit.o kboss.o logen.o logen4.o logen5.o\
logen6.o logen7.o logen8.o logen9.o logit.o logit2.o logit3.o\
logit4.o logit5.o logit6.o logit7.o lusim.o lvdof.o lvdofn.o\
lvdonn.o ma2ad.o ma2en.o ma2fm.o ma2if.o ma2mv.o ma2rp.o\
ma2rx.o ma2tp.o ma2vc.o mdnam.o move.o mv2ma.o numsc.o\
phcal.o poshd.o posit.o radec.o rp2ma.o rplnk.o\
run_matcn.o rx2ma.o rxvtot.o sbit.o sidtm.o tp2ma.o updat.o\
upper.o vc2ma.o vlt2mic.o vlt_head.o\
put_cons.o put_cons_raw.o putcon_ch.o sun.o zero_vatt.o
#
#CFLAGS = -g
FFLAGS = -X426 -g
F77 = gf77
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
fslb.a: $(OBJECTS)
	touch fslb.a
	rm fslb.a
	ar qc fslb.a $(OBJECTS)
