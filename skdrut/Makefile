#########################################################################
#                                                                       #
#                           skdrutils                                   #
#                                                                       #
# Makefile for sked/drudg utilities library. These routines are used by #
# both sked and drudg. Utilities used by only one program are found in  #
# separate libraries called skutils and drutils.                        #
#                                                                       #
#    2019Aug26
#########################################################################
 
ARC = skdrut.a

OBJECTS=\
    add_slash_if_needed.o \
    addscan.o \
    apstar_rad.o \
    atape.o \
    azwrap.o \
    axtyp.o \
    cablw.o \
    capitalize.o \
    ckiau.o \
    ckroll.o \
    clndr.o \
    cvpos.o \
    check_rec_type.o \
    check_rack_type.o \
    count_freq_tracks.o \
    ctime2ydhms.o \
    ctime2dmjd.o \
    c2lower.o \
    c2upper.o \
    delete_file.o \
    dsecdif.o \
    dot8.o \
    durscan.o \
    errormsg.o \
    extractnexttoken.o \
    fc_gwinsz.o \
    fc_gwinw.o \
    feetscan.o \
    findscan.o \
    freq_init.o \
    frinit.o  \
    frinp.o \
    gdate.o \
    gdscan.o \
    getiauname.o \
    gnpas.o \
    hdinp.o \
    hms2seconds.o \
    hol2lower.o \
    hol2upper.o \
    i2long.o \
    iday0.o \
    idchk.o \
    ind.o \
    ifill4.o \
    ifirst_non_blank.o \
    ifirst_non_white.o  \
    igetstatnum.o \
    igetstatnum2.o \
    igetsrcnum.o \
    igtba.o igtfr.o  \
    indexx_string.o \
    iroll_def.o \
    istringminmatch.o \
    itras.o \
    itimedifsec.o \
    ivgtmo.o \
    ivgtst.o \
    iwhere_in_string_list.o \
    iwhere_in_string_list_nocase.o \
    iwhere_in_int_list.o \
    iwhere_in_real8_list.o \
    julda.o \
    kbit.o \
    kcont.o \
    kearl.o \
    kget_response.o \
    knewt.o \
    ktimedif.o \
    kvalid_rack.o \
    kvalid_rec.o \
    lower.o \
    lowercase.o \
    lowercase_and_write.o \
    lyes_no.o \
    mjd2yrdoy.o \
    mpstar_rad.o \
    m3mode.o \
    make_unit_vector.o \
    newscan.o \
    novas.o \
    null_term.o \
    obs_sort.o \
    pid_str.o \
    plh.o \
    pnum.o \
    prefr.o \
    printer.o \
    purge_file.o  \
    put_esc_in_string.o \
    raded.o  \
    read_nolf.o \
    readf_asc.o \
    reads.o \
    readline_skdrut.o \
    sbit.o \
    secnds.o \
    seconds2hms.o \
    sec2minsec.o selev.o \
    searl.o \
    sidtm.o  \
    sktime.o \
    slate.o \
    slewo.o \
    soinp.o speed.o  \
    splitntokens.o \
    splitntokens2.o \
    squeezeleft.o \
    stape.o \
    stinp.o \
    sunarc.o \
    sunpo.o \
    sunazel.o \
    ttape.o \
    timesub.o \
    timeadd.o \
    tmadd.o \
    tmsub.o \
    trimlen.o \
    tspin.o \
    unpbar.o \
    unpco.o \
    unpfsk.o \
    unpfcat.o \
    unpfmt.o \
    unphd.o \
    unplo.o \
    unprat.o \
    unpva.o \
    unpvh.o \
    unpvp.o \
    unpvt.o \
    update_string_list.o \
    upper.o \
    valid_hardware_blk.o \
    vglinp.o \
    vsoinp.o \
    vmoinp.o \
    vstinp.o \
    vread.o \
    vunpfrq.o \
    vunptrk.o \
    vunpant.o \
    vunpdas.o \
    vunpsit.o \
    vunpant.o \
    vunpso.o \
    vunpif.o \
    vunpbbc.o \
    vunptrk.o \
    vunphp.o \
    vunps2m.o \
    vunps2g.o \
    vunproll.o \
    vunpprc.o \
    vobinp.o  \
    vunppcal.o \
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

CPPFLAGS+=-DF2C
FFLAGS+=-ff2c -I/usr2/fs-git//include -fno-range-check -finit-local-zero -fbackslash
# -fno-automatic

$(ARC): $(OBJECTS)
	touch $(ARC)
	rm $(ARC)
	ar rcs $(ARC) $(OBJECTS)
# The following command indexes the archive for Linux. Not needed for HP.
$(AR_INDEX)
