#########################################################################
#                                                                       #
#                           skdrutils                                   #
#                                                                       #
# Makefile for sked/drudg utilities library. These routines are used by #
# both sked and drudg.                        #
#                                                                       #
# 2005Aug13  JMGipson. Cleaned and alphabetized.
#########################################################################
 
ARC = skdrut.a

#    iday_of_year.o \
#    skdrini.o 
#    tmjd.o \

OBJECTS=\
    add_slash_if_needed.o \
    addscan.o \
    apstar_rad.o \
    atape.o axtyp.o azwrap.o \
    cablw.o \
    capitalize.o check_rec_type.o \
    ckiau.o clndr.o cvpos.o \
    count_freq_tracks.o \
    ctime2ydhms.o \
    ctime2dmjd.o c2lower.o c2upper.o \
    delete_file.o dsecdif.o dot8.o \
    errormsg.o extractnexttoken.o fc_gwinsz.o fc_gwinw.o \
    findscan.o freq_init.o frinit.o  frinp.o \
    gdate.o \
    getiauname.o \
    hol2lower.o hol2upper.o hms2seconds.o \
    iday_of_year.o idchk.o ifill4.o ifirst_non_blank.o ifirst_non_white.o  \
    igtba.o igtfr.o  \
    indexx_string.o \
    itras.o itimedifsec.o iday0.o igetstatnum.o igetstatnum2.o igetsrcnum.o \
    istringminmatch.o ivgtmo.o ivgtst.o iwhere_in_range4.o \
    iwhere_in_string_list.o iwhere_in_string_list_nocase.o iwhere_in_int_list.o iwhere_in_real8_list.o ind.o i2long.o \
    julda.o \
    kbit.o kcont.o kearl.o knewt.o ktimedif.o kget_response.o \
    kvalid_rack.o kvalid_rec.o \
    lower.o lowercase.o lowercase_and_write.o lyes_no.o \
    make_unit_vector.o \
    mjd2yrdoy.o mpstar_rad.o \
    newscan.o novas.o null_term.o obs_sort.o pid_str.o \
    plh.o pnum.o prefr.o printer.o purge_file.o  put_esc_in_string.o \
    raded.o  readf_asc.o read_nolf.o reads.o \
    readline_skdrut.o \
    sbit.o secnds.o seconds2hms.o sec2minsec.o selev.o searl.o sidtm.o skdrini.o sktime.o \
    slewo.o slew_time.o soinp.o speed.o  splitntokens.o splitntokens2.o squeezeleft.o \
    stape.o stinp.o store_rack_and_recorder.o sunarc.o \
    sunpo.o sunazel.o \
    ttape.o timesub.o timeadd.o tmadd.o tmsub.o trimlen.o tspin.o \
    unpbar.o unpco.o unpfsk.o unpfcat.o unpfmt.o unplo.o  unprat.o \
    unpvh.o  unpvt.o update_string_list.o upper.o \
    valid_hardware_blk.o \
    vunpfrq.o vunptrk.o vunpant.o vunpdas.o vunpsit.o vunpant.o vglinp.o vunpso.o \
    vunpif.o vunpbbc.o vunptrk.o vsoinp.o vmoinp.o vstinp.o vread.o \
    vunpprc.o vobinp.o  vunppcal.o \
    write_return_if_needed.o \
    write_error_and_pause.o \
    writf_asc.o \
    writf_asc_ch.o \
    xat.o \
    xyz2latlon.o \
    ydjul.o \
    ymday.o 


# Use -G for the profiler
#if the following is uncommented, sked does not work
#FFLAGS=-C -c -g
#FFLAGS=-C -c -G
#CFLAGS=-C -c

#CC:=$(CC)
#FC:=$(FORT)

ifdef FS_VERSION
ifeq ($(FC),f77)
FC=f95
endif
ARCHIV=ar -sqc
ifeq ($(FC),fort77)
FFLAGS=-C -c
CFLAGS= -c -DF2C
else
FFLAGS=-fno-range-check -fno-underscoring -g -D READ_LINE
ifeq ($(shell uname -m),x86_64)
FFLAGS+=-fdefault-integer-8 -finteger-4-integer-8
endif
ifneq ($(FS_F95_NO_ALLOW_ARGUMENT_MISMATCH),1)
FFLAGS += -fallow-argument-mismatch
endif
endif
endif

$(ARC): $(OBJECTS)
	touch $(ARC)
	rm $(ARC)
	$(ARCHIV)  $(ARC) $(OBJECTS)
# The following command indexes the archive for Linux. Not needed for HP.
$(AR_INDEX)

