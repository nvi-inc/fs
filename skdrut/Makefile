#########################################################################
#                                                                       #
#                           skdrutils                                   #
#                                                                       #
# Makefile for sked/drudg utilities library. These routines are used by #
# both sked and drudg. Utilities used by only one program are found in  #
# separate libraries called skutils and drutils.                        #
#                                                                       #
# 951017 nrv Initial version                                            #
# 951019 nrv Changes for VLBA modes and LO per channel                  #
#                                                                       #
#########################################################################
 
ARC = skdrut
IN = ../include-new/
 
OBJECTS=\
aposn.o axtyp.o backward.o cablw.o ckiau.o clear_array.o clndr.o\
cvpos.o flinp.o forward.o frinp.o gnpas.o hdinp.o hol2lower.o\
hol2upper.o iday0.o idate.o igtba.o igtfr.o igtso.o igtst.o igtst2.o\
in2a2.o inc.o ind.o initf.o julda.o kbit.o kcont.o kearl.o knaeq.o\
locf.o lower.o novas.o null_term.o pid_str.o posnt.o prefr.o \
raded.o ras2b.o rdctl.o readf_asc.o reads.o reio.o sbit.o secnds.o\
sidtm.o slewo.o slewt.o soinp.o speed.o stinp.o sunarc.o sunazel.o\
sunpo.o trimlen.o tspin.o unpco.o unpfl.o unpfsk.o unpfcat.o unphd.o \
unplo.o unpso.o unpva.o unpvh.o unpvp.o unpvt.o unpwc.o\
unpwo.o upper.o writf_asc.o writf_asc_ch.o xat.o\
ydjul.o ymday.o printer.o 
#
FFLAGS=-C -c -g -I$(IN)
CFLAGS= -c -g
#
$(ARC).a: $(OBJECTS)
	touch $(LIB)$(ARC).a
	rm $(LIB)$(ARC).a
	ar -qc $(LIB)$(ARC).a $(OBJECTS)
# The following command indexes the archive for Linux. Not needed for HP.
	ar s $(LIB)$(ARC).a
