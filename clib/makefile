# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#
CFLAGS += -DRELEASE=$(RELEASE)
ifdef NO_FTOK_FS
override CFLAGS +=  -DNO_FTOK_FS
endif
#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
cls_util.o prog_exec.o sem_util.o shm_util.o skd_util.o setup_ids.o\
incom_ini.o nsem_util.o brk_util.o\
get_vatod.o lvdofn_v.o lvdonn_v.o head_vmov.o mcbcn_v.o vset_zero.o\
req_util.o res_util.o dist_util.o arg_util.o str_util.o mcbcn_v2.o\
dtlkup.o tpi_vlba.o vrepro_util.o freq2bbc.o bbc_util.o tape_util.o\
vform_util.o venable_util.o dqa_util.o capture_util.o et_v.o rwff_v.o\
vst_util.o get_vaux.o set_vaux.o cchmod.o sig_ignore.o get_vtime.o\
mcb_util.o bblv2db.o motion_done.o mvdis_v.o vacuum.o semid_util.o\
go_util.o get_vatod.o v2_head_vmov.o v2_motion_done.o v2_vlt_head.o\
trkfrm_util.o bs2code.o cshm_init.o tracks_util.o bit_density_util.o\
systracks_util.o rclcn_req_util.o rclcn_res_util.o rcl_util.o\
user_info_util.o s2st_util.o s2tape_util.o s2rec_util.o rec_mode_util.o\
data_valid_util.o s2label_util.o get_s2time.o tracks4_util.o trkfrm4_util.o\
bsfo2code.o form4_util.o mvupper.o setMK4FMrec.o rvac_util.o wvolt_util.o\
lo_util.o pcalform_util.o pcald_util.o pcalports_util.o dqa4_cnvrt.o\
ib_util.o k4ib_util.o k4st_util.o k4tape_util.o k4rec_util.o get_k3time.o\
k4vclo_util.o k4vc_util.o k4vcif_util.o k4vcbw_util.o k3fm_util.o set_k3aux.o\
get_k4time.o v_vlt_head.o k4label_util.o k4rec_mode_util.o k4recpatch_util.o\
rp2code.o k4pcalports_util.o rp2codek41.o rp2codek42.o tpi_norack.o\
selectcmd_util.o rollform_util.o mk4vcd.o vlbabbcd.o mk4bbcd.o tpicd_util.o\
onoff_util.o flux_val.o find_next_noncomment.o get_tcal_fwhm.o get_gain_par.o\
calrx_util.o ds_util.o dscon_util.o bsfo2vars.o lbaifpd.o lba_cor_util.o \
lba_ft_util.o lba_ifp_util.o lba_mon_util.o lba_trkfrm_util.o tpi_lba.o \
dscon_v.o fsmetc.o get_rxgain.o lower.o disk_serial_util.o disk_pos_util.o\
m5_utils.o data_check_util.o disk_record_util.o bank_check_util.o\
disk2file_util.o in2net_util.o user_device_util.o ntp_synch.o\
scan_check_util.o mk5b_mode_util.o vsi4_util.o mk5vcd.o mk5bbcd.o\
dot_util.o get_5btime.o mk5_status_util.o pps_source_util.o clock_set_util.o play_wav.o\
holog_util.o satellite_util.o satoff_util.o dbbcnn_util.o dbbcifx_util.o\
dbbcform_util.o tpi_dbbc.o mk5dbbcd.o dbbcn_v.o dbbc_cont_cal_util.o\
dbbc_if_power.o dbbcgain_util.o fila10g_mode_util.o daymy.o get_fila10gtime.o\
antcn_term.o dbbc_vsix_util.o dbbc_version_check.o mk5dbbcd_pfb.o\
tpi_dbbc_pfb.o dbbcn_pfb_v.o fserr_cls.o if_cmd.o dbbc_pfbx_util.o helpstr.o\
dbbcvsi_clk_util.o
#
#FFLAGS = 
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
clib.a: $(OBJECTS)
	touch clib.a
	rm clib.a
	ar -qc clib.a $(OBJECTS)
	ar s clib.a
