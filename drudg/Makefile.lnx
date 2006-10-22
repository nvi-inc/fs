#######################################################################
#                                                                     #
#                         makefile for DRUDG                          #
# 2005Sep02 JMG Cleaned up makefile.                                  #
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
OBJECTS=\
b3of9.o bar1.o bbbuf.o bbsyn.o bcode.o blabl.o \
cazel.o cbinf.o checkmk5xlat.o chkgrpandwrite.o ckobs.o clist.o \
copen.o counter_init.o \
delete_comma_and_write.o drchmod.o drprrd.o drset.o drudg_lnx.o dsnout.o \
equip_type.o fakesum.o fc_chmod.o fdrudg.o find_num_chans_rec.o find_recorder_speed.o \
fix_snap_file.o fspin.o get_version.o getqual.o getstr.o gtsnp.o \
iaddk4.o iaddpc.o iaddtr.o init_hardware_common.o k4proc_type.o kcheckgrpor.o \
label.o lablog.o labsnp.o lists.o lspin.o lstsum.o lstsum_info.o lstsumo.o \
luff.o lv_open.o m3inf.o name_trkf.o nhdif.o \
point.o port.o prcov.o prcov_vex.o proc_exper_initi.o proc_mk5_init1.o \
proc_mk5_init2.o proc_postob_mk5a.o proc_write_define.o procintr.o procs.o \
prtmp.o prtxt.o psbar.o purge_file.o read_snap1.o read_snap6.o \
setprint.o setup_name.o setup_printer.o skdshft.o snap.o \
snap_bit_density.o snap_check.o snap_data_valid.o snap_disk_check.o \
snap_disk_end.o snap_disk2file_abort.o snap_enable.o snap_et.o snap_fast.o \
snap_hol_wrt.o snap_ifd.o snap_in2net_connect.o snap_info.o snap_midtp.o \
snap_monitor.o snap_pass.o snap_pcalf.o snap_prepass.o snap_readtime.o \
snap_ready.o snap_rec.o snap_recalc_speed.o snap_recp.o snap_rollform.o \
snap_rw.o snap_s2_loader.o snap_s2_unloader.o snap_setup.o snap_st.o \
snap_start_recording.o snap_systracks.o snap_tape.o snap_tapef.o snap_tpicd.o \
snap_unload_tape.o snap_unlod.o snap_wait_sec.o snap_wait_time.o snapintr.o \
spdstr.o squeezeleft.o squeezewrite.o sread.o strip_path.o \
timin.o timout.o trkall.o unpsk.o vlbah.o vlbat.o \
wrdate.o wrday.o wrdur.o wrhead.o wrsor.o wrtap.o wrtrack.o xfer_override.o




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
../bin/$(PROGRAM): $(OBJECTS) 
	rm -f ./core
	@echo Linking $(PROGRAM)...
	@$(FC) -o ../bin/$(PROGRAM) $(OBJECTS) $(LIBS)
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


