#######################################################################
#                                                                     #
#                         makefile for DRUDG                          #
#    2019Aug14  JMGipson some cleanup                                 #
#                                                                     #
#######################################################################
# For FS version
#
# Set paths
#

SRCDIR=../

PROGRAM = drudg
#
# Set objects
#
OBJECTS=    \
   b3of9.o  \
   bar1.o   \
   bbbuf.o  \
   bbsyn.o  \
   bcode.o  \
   blabl.o  \
   cazel.o  \
   cband_char.o \
   cbinf.o \
   checkmk5xlat.o \
   check_csb_list.o \
   check_dbbc_setup.o \
   chkgrpandwrite.o \
   ckobs.o \
   clist.o \
   copen.o \
   copy_time.o \
   counter_init.o \
   crelease.o \
   delete_comma_and_write.o \
   drchmod.o \
   drprrd.o \
   drset.o \
   drudg.o \
   drudg_rdctl.o \
   drudg_write.o \
   dsnout.o \
   drudg_write_comment.o \
   equip_type.o \
   fakesum.o \
   fdrudg.o \
   find_num_chans_rec.o \
   find_recorder_speed.o \
   get_version.o \
   getqual.o \
   getstr.o \
   gtsnp.o \
   iaddpc.o \
   iaddtr.o \
   init_hardware_common.o \
   kcheckgrpor.o \
   label.o \
   lablog.o \
   labsnp.o \
   lists.o \
   lspin.o \
   lstsum.o \
   lstsum_info.o \
   lstsumo.o \
   luff.o \
   lv_open.o  \
   nhdif.o \
   point.o \
   port.o \
   prcov.o \
   prcov_vex.o \
   proc_check8bbc.o \
   proc_from_sked.o \
   proc_exper_initi.o \
   proc_form.o \
   proc_ifd.o \
   proc_lo.o  \
   proc_mk5_init1.o \
   proc_mk5_init2.o \
   proc_disk_tracks.o \
   proc_norack.o \
   proc_patch.o \
   proc_pcalf.o \
   proc_s2_comments.o \
   proc_sked_proc.o \
   proc_setup.o \
   proc_dbbc_pfb_tracks.o \
   proc_tracks.o \
   proc_trkf.o \
   proc_track_mask_lines.o \
   proc_vcname.o \
   proc_vc_cmd.o \
   proc_vracks_bbc.o \
   proc_lba_ifp.o \
   proc_mracks_vc.o \
   proc_dbbc_bbc.o \
   proc_write_define.o \
   procintr.o procs.o \
   prtmp.o \
   prtxt.o \
   psbar.o \
   read_broadband_section.o \
   read_snap1.o \
   read_snap6.o \
   setprint.o \
   setup_name.o \
   setup_printer.o \
   skdshft.o \
   skdrini.o \
   snap.o \
   snap_bit_density.o \
   snap_check.o \
   snap_data_valid.o \
   snap_disk_check.o \
   snap_disk_end.o \
   snap_disk2file_abort.o \
   snap_enable.o \
   snap_et.o \
   snap_fast.o \
   snap_hol_wrt.o \
   snap_in2net_connect.o \
   snap_info.o \
   snap_midtp.o \
   snap_monitor.o \
   snap_pass.o \
   snap_pcalf.o \
   snap_prepass.o \
   snap_readtime.o \
   snap_ready.o \
   snap_rec.o \
   snap_recalc_speed.o \
   snap_recp.o \
   snap_rollform.o \
   snap_rw.o \
   snap_st.o \
   snap_start_recording.o \
   snap_systracks.o \
   snap_tpicd.o \
   snap_wait_sec.o \
   snap_wait_time.o \
   snapintr.o \
   spdstr.o  \
   sread.o \
   strip_path.o \
   timin.o \
   timout.o \
   trkall.o \
   unpsk.o \
   vlbah.o \
   vlbat.o \
   wrdate.o \
   wrday.o \
   wrdur.o \
   wrhead.o \
   wrsor.o \
   write_drudg_version_line.o \
   xfer_override.o


# Flags for the profiler. Make sure you are using grt0 in the linker.
#FFLAGS=-c -C -G
#CFLAGS=-c -C -G
# Use these flags for optimizing (incompatible with debugging).
# Make sure you are using crt0 in the linker.
#FFLAGS=-c -C +O3 +Onolimit
#CFLAGS=-c -C

LDFLAGS:=\
../skdrut/skdrut.a \
../../sked_dev/lnfch/lnfch.a \
../../sked_dev/curses/curses.a \
../../sked_dev/vex/vex64.a \
-lz -lm -lc \
 -lfl

#-Lusr/src/atlas-3.4.1/lib/Linux_P4SSE2/ -lf77blas -latlas \

# NOTE: Use /lib/crt0 if you are NOT using the profiler.
#       Use /lib/gcrt0 if you ARE using the profiler.
$(PROGRAM): $(OBJECTS)
	@echo Linking DRUDG...
#       @f77 -o $(SK)$(PROGRAM) $(OBJECTS) $(LDFLAGS)
	$(FC) -o $(SK)$(PROGRAM) $(OBJECTS) $(LDFLAGS) -L/usr/lib/gcc-lib/i586-mandrake-linux-gnu/3.3.1 -D READ_LINE
	@echo done.

clean:
	rm -f *.o; rm -f *.a; rm -f sked


