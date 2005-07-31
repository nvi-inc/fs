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
# 960602 nrv Changes for VEX file reading                               #
# 970118 nrv Add vunpprc and unpfmt.                                    #
# 970124 nrv Add errormsg.                                              #
# 970114 nrv Add UNPPRE for Vex 1.5                                     #
# 970115 nrv Add UNPFMT for recording format                            #
# 970317 nrv Move IGTKY, SEARL, SELEV, STAPE, i2long here from sked     #
# 970319 nrv Move KNEWT here from sked and drudg                        #
# 970329 nrv Remove SLEWT to sked because only sked calls it.           #
# 970406 nrv Move c2upper here from drudg                               #
# 970722 nrv Add feetscan, durscan, gdscan                              #
# 971211 nrv Add VUNPPCAL.                                              #
# 990217 nrv Add LSKORDER.                                              #
# 990629 nrv Add SLATE and TTAPE.                                       #
# 991108 nrv Add SKDRINI. Move ISECDIF from drudg to here.              #
# 000620 nrv Add OBS_SORT, remove LSKORDER and SKORDER.                 #
# 000620 nrv Add SNAME, M3MODE, ATAPE.                                  #
# 000929 nrv Add TMADD, TMSUB                                           #
# 001109 nrv Add IVGTST, replace VOB1INP with VOBINP                    #
# 020214 nrv Add CKROLL
# 030122 JMG Added itimedifsec,timesub,timeadd,ktimedif,clower          #
#########################################################################
 
ARC = skdrut
 
OBJECTS=\
lyes_no.o istringminmatch.o itimedifsec.o timesub.o timeadd.o ktimedif.o c2lower.o\
capitalize.o lowercase.o  ifill4.o xyz2latlon.o iwhere_in_string_list.o mpstar_rad.o \
count_freq_tracks.o apstar_rad.o \
readline.o iroll_def.o itras.o getiauname.o ckiau.o \
splitntokens.o  extractnexttoken.o  \
sktime.o \
aposn.o axtyp.o backward.o cablw.o ckiau.o clear_array.o clndr.o\
cvpos.o  forward.o frinp.o gnpas.o hdinp.o hol2lower.o\
hol2upper.o iday0.o idate.o igtba.o igtfr.o igtso.o igtst.o igtst2.o\
inc.o ind.o initf.o julda.o kbit.o kcont.o kearl.o knaeq.o\
locf.o lower.o novas.o null_term.o pid_str.o posnt.o prefr.o \
raded.o ras2b.o rdctl.o readf_asc.o reads.o reio.o sbit.o secnds.o\
sidtm.o slewo.o soinp.o speed.o stinp.o sunarc.o sunazel.o\
sunpo.o trimlen.o tspin.o unpco.o  unpfsk.o unpfcat.o unphd.o \
unplo.o unpso.o unpva.o unpvh.o unpvp.o unpvt.o unpwc.o\
unpwo.o upper.o writf_asc.o writf_asc_ch.o xat.o idchk.o\
ydjul.o ymday.o printer.o unprat.o unpbar.o unpfmt.o \
vunpfrq.o vunptrk.o vunpant.o vunpdas.o vunpsit.o vunpant.o \
vglinp.o vunpso.o vunpif.o vunpbbc.o vunptrk.o vunphp.o \
vsoinp.o vob1inp.o vobinp.o vmoinp.o vstinp.o ivgtmo.o ivgtso.o \
vread.o addscan.o findscan.o newscan.o pnum.o knewt.o c2upper.o \
frinit.o vunps2m.o vunps2g.o vunproll.o vunpprc.o errormsg.o \
fc_gwinsz.o fc_gwinw.o igtky.o selev.o stape.o searl.o i2long.o \
feetscan.o durscan.o gdscan.o vunppcal.o ttape.o \
slate.o skdrini.o isecdif.o m3mode.o sname.o atape.o obs_sort.o \
tmadd.o tmsub.o ivgtst.o ckroll.o
#
FFLAGS=-C -c
# f2c needs this others don't
CFLAGS= -DF2C
CFLAGS= -c -DF2C
#
$(ARC).a: $(OBJECTS)
	touch $(LIB)$(ARC).a
	rm $(LIB)$(ARC).a
	ar -qc $(LIB)$(ARC).a $(OBJECTS)
# The following command indexes the archive for Linux. Not needed for HP.
	ar s $(LIB)$(ARC).a
