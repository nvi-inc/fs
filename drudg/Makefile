#######################################################################
#                                                                     #
#                         makefile for DRUDG                          #
# 960201 nrv for Linux                                                #
# 960602 nrv with vex libraries                                       #
# 970312 nrv Add read_snap1                                           #
# 970319 nrv Move knewt to skdrut                                     #
# 970401 nrv Add DRSET                                                #
# 970406 nrv Move c2upper to skdrut                                   #
# 970509 nrv Add WRSOR                                                #
# 970603 nrv Add PRCOV                                                #
# 971211 nrv Add IADDPC                                               #
# 981001 nrv Add PRTXT                                                #
# 981001 nrv Add K4TYPE                                               #
# 990113 nrv Add k4proc_type, k4snap_type. Remove k4type              #
# 990113 nrv Add TIMOUT, TIMIN                                        #
# 990304 nrv Add IADDK4, WRDAY                                        #
# 990730 nrv add EQUIP_TYPE                                           #
# 991108 nrv add SET_TYPE, SETUP_NAME, SNAP_INFO, LSTSUM_INFO         #
# 991108 nrv move ISECDIF to skdrutil. add READ_SNAP6                 #
# 991118 nrv Remove SNPSHFT                                           #
# 000620 nrv RAdd FAKESUM, LV_OPEN, PRCOV_VEX                         #
# 010104 nrv Move TMADD, TMSUB to skdrut                              #
# 021002 nrv Add DRPRRD                                               #
# 021017 nrv Add FSPIN                                                #
# 2003Jan22 JMG Rewritten lstsum,lst_info,lstsumo, snap,procs         #
#######################################################################

all: ../bin/drudg ../bin/ifvlbafix

# For FS version
ifndef VERSION
VERSION = 0
PATCHLEVEL = 0
SUBLEVEL = 0
endif
#
# Set paths
#

SRCDIR=../

DR = $(SRCDIR)drudg/
UT = $(SRCDIR)skdrut/
PROGRAM = drudg

#
# Set objects
#
DROBS=\
$(DR)chkgrpandwrite.o $(DR)counter_init.o \
$(DR)find_num_chans_rec.o $(DR)find_recorder_speed.o\
$(DR)kcheckgrpor.o $(DR)init_hardware_common.o\
$(DR)name_trkf.o \
$(DR)proc_exper_initi.o $(DR)proc_mk5_init1.o $(DR)proc_mk5_init2.o\
$(DR)proc_write_define.o $(DR)purge_file.o \
$(DR)squeezeleft.o $(DR)squeezewrite.o \
$(DR)snap_bit_density.o $(DR)snap_check.o \
$(DR)snap_data_valid.o  \
$(DR)snap_disc_check.o $(DR)snap_disc_end.o  $(DR)snap_enable.o\
$(DR)snap_et.o $(DR)snap_fast.o $(DR)snap_hol_wrt.o $(DR)snap_ifd.o\
$(DR)snap_midtp.o $(DR)snap_monitor.o $(DR)snap_prepass.o $(DR)snap_pass.o\
$(DR)snap_pcalf.o \
$(DR)snap_readtime.o $(DR)snap_recalc_speed.o \
$(DR)snap_ready.o $(DR)snap_rec.o $(DR)snap_recp.o $(DR)snap_rollform.o $(DR)snap_rw.o $(DR)snap_setup.o\
$(DR)snap_st.o $(DR)snap_start_recording.o $(DR)snap_systracks.o $(DR)snap_tape.o \
$(DR)snap_s2_unloader.o $(DR)snap_s2_loader.o \
$(DR)snap_tapef.o $(DR)snap_tpicd.o \
$(DR)snap_unload_tape.o $(DR)snap_unlod.o \
$(DR)snap_wait_sec.o $(DR)snap_wait_time.o \
$(DR)strip_path.o \
$(DR)crprc.o \
$(DR)ckobs.o $(DR)clist.o $(DR)drudg.o $(DR)gtsnp.o \
$(DR)lists.o $(DR)lspin.o $(DR)m3inf.o $(DR)point.o \
$(DR)procs.o $(DR)snap.o  $(DR)sread.o \
$(DR)unpsk.o $(DR)fdrudg.o $(DR)spdstr.o $(DR)drset.o \
$(DR)iaddtr.o $(DR)setba_dr.o $(DR)wrdur.o $(DR)wrtap.o $(DR)wrsor.o\
$(DR)label.o $(DR)blabl.o $(DR)wrtrack.o  $(DR)wrhead.o \
$(DR)cmshf.o $(DR)tshft.o $(DR)getqual.o $(DR)bbsyn.o \
$(DR)skdshft.o $(DR)snpshft.o $(DR)luff.o $(DR)cbinf.o $(DR)bcode.o \
$(DR)snapintr.o $(DR)bbbuf.o $(DR)cazel.o $(DR)gtshft.o $(DR)bar1.o \
$(DR)labsnp.o $(DR)port.o $(DR)lstsum.o $(DR)nhdif.o $(DR)setprint.o \
$(DR)shfcop.o $(DR)getstr.o $(DR)prtmp.o $(DR)wrdate.o \
$(DR)b3of9.o $(DR)dsnout.o $(DR)trkall.o  $(DR)timout.o \
$(DR)fc_chmod.o $(DR)vlbat.o $(DR)vlbah.o $(DR)drchmod.o \
$(DR)lstsumo.o $(DR)copen.o $(DR)psbar.o \
$(DR)procintr.o $(DR)read_snap1.o $(DR)prcov.o $(DR)iaddpc.o \
$(DR)prtxt.o $(DR)timin.o $(DR)k4proc_type.o $(DR)iaddk4.o \
$(DR)wrday.o $(DR)equip_type.o $(DR)snap_info.o \
$(DR)setup_name.o $(DR)read_snap6.o $(DR)lstsum_info.o \
$(DR)fakesum.o $(DR)lv_open.o  $(DR)prcov_vex.o $(DR)drprrd.o \
$(DR)fspin.o





#
# Set compiling and linking flags
#
# -C checks for out of bounds during execution and aborts if found
FFLAGS= -C -c -cpp -DVERSION=$(VERSION) \
-DSUBLEVEL=$(SUBLEVEL) -DPATCHLEVEL=$(PATCHLEVEL)
# f2c needs this others don't
CFLAGS= -c  -DF2C
#

#
LIBS=$(UT)skdrut.a ../lnfch/lnfch.a ../fslb/fslb.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../vex/vex.a -lf2c -lfl
#
../bin/$(PROGRAM): $(DROBS) 
	rm -f ./core
	@echo Linking $(PROGRAM)...
	@$(FC) -o ../bin/$(PROGRAM) $(DROBS) $(LIBS)
	@strip ../bin/$(PROGRAM)
	@echo done.

../bin/ifvlbafix: ifvlbafix
	rm -f ../bin/ifvlbafix
	ln -s ../drudg/ifvlbafix ../bin/ifvlbafix

#  The following are special dependency lines for compiling.

.f.o:
	cd $(<D); $(FC) $(FFLAGS) $<
.c.o:
	cd $(<D); cc $(CFLAGS) $<


