#########################################################################
#                                                                       #
#                           skdrutils                                   #
#                                                                       #
# Makefile for sked/drudg utilities library. These routines are used by #
# both sked and drudg. Utilities used by only one program are found in  #
# separate libraries called skutils and drutils.                        #
#                                                                       #
# 2005Aug13  JMGipson. Cleaned and alphabetized.
#########################################################################
 
ARC = skdrut

OBJECTS=\
add_slash_if_needed.o  addscan.o apstar_rad.o atape.o axtyp.o  \
cablw.o caldat.o capitalize.o ckiau.o ckroll.o clndr.o cvpos.o \
check_rec_type.o check_rack_type.o \
count_freq_tracks.o ctime2ydhms.o ctime2dmjd.o c2lower.o c2upper.o \
dsecdif.o dot8.o durscan.o errormsg.o extractnexttoken.o fc_gwinsz.o fc_gwinw.o \
feetscan.o findscan.o freq_init.o frinit.o  frinp.o \
gdscan.o getiauname.o gnpas.o hdinp.o hol2lower.o hol2upper.o hms2seconds.o \
idchk.o ifill4.o ifirst_non_blank.o ifirst_non_white.o igtba.o igtfr.o  \
iroll_def.o isecdif.o itras.o itimedifsec.o iday0.o igetstatnum.o igetstatnum2.o igetsrcnum.o \
istringminmatch.o ivgtmo.o ivgtst.o iwhere_in_string_list.o iwhere_in_real8_list.o ind.o i2long.o \
mjd2yrdoy.o julda.o kbit.o kcont.o kearl.o knewt.o ktimedif.o \
lower.o lowercase.o lowercase_and_write.o lyes_no.o mpstar_rad.o m3mode.o \
newscan.o novas.o null_term.o obs_sort.o pid_str.o \
plh.o pnum.o prefr.o printer.o purge_file.o  put_esc_in_string.o \
raded.o  rdctl.o readf_asc.o readline_skdrut.o reads.o \
sbit.o secnds.o seconds2hms.o sec2minsec.o selev.o searl.o sidtm.o skdrini.o sktime.o slate.o \
slewo.o soinp.o speed.o  splitntokens.o splitntokens2.o squeezeleft.o stape.o stinp.o sunarc.o \
sunpo.o sunazel.o \
ttape.o timesub.o timeadd.o tmadd.o tmsub.o trimlen.o tspin.o \
unpbar.o unpco.o unpfsk.o unpfcat.o unpfmt.o unphd.o unplo.o  unprat.o \
unpva.o unpvh.o unpvp.o unpvt.o update_string_list.o upper.o \
valid_hardware_blk.o \
vunpfrq.o vunptrk.o vunpant.o vunpdas.o vunpsit.o vunpant.o vglinp.o vunpso.o \
vunpif.o vunpbbc.o vunptrk.o vunphp.o vsoinp.o vmoinp.o vstinp.o vread.o \
vunps2m.o vunps2g.o vunproll.o vunpprc.o vobinp.o  vunppcal.o \
write_error_and_pause.o writf_asc.o writf_asc_ch.o xat.o xyz2latlon.o ydjul.o ymday.o


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
