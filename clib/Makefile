#
# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#
ifdef NO_FTOK_FS
override CFLAGS +=  -DNO_FTOK_FS
endif
#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
antcn_term.o arg_util.o bank_check_util.o bbc_util.o bblv2db.o \
bit_density_util.o brk_util.o bs2code.o bsfo2code.o bsfo2vars.o calrx_util.o \
capture_util.o cchmod.o clock_set_util.o cls_util.o cshm_init.o \
data_check_util.o data_valid_util.o daymy.o dbbc3_bbcnn_util.o \
dbbc3_cont_cal_util.o dbbc3_if_power.o dbbc3_iftpx_util.o dbbc3_ifx_util.o \
dbbc3n_v.o dbbc_cont_cal_util.o dbbc_if_power.o dbbc_pfbx_util.o \
dbbc_version_check.o dbbc_vsix_util.o dbbcform_util.o dbbcgain_util.o \
dbbcifx_util.o dbbcn_pfb_v.o dbbcn_v.o dbbcnn_util.o dbbcvsi_clk_util.o disk2file_util.o \
disk_pos_util.o disk_record_util.o disk_serial_util.o dist_util.o dot_util.o \
dqa4_cnvrt.o dqa_util.o ds_util.o dscon_util.o dscon_v.o dtlkup.o et_v.o \
fila10g_mode_util.o find_next_noncomment.o flux_val.o form4_util.o freq2bbc.o \
fserr_cls.o fsmetc.o get_5btime.o get_RDBEtime.o get_fila10gtime.o \
get_gain_par.o get_k3time.o get_k4time.o get_rxgain.o get_s2time.o \
get_tcal_fwhm.o get_vatod.o get_vaux.o get_vtime.o go_util.o head_vmov.o \
helpstr.o holog_util.o ib_util.o if_cmd.o in2net_util.o incom_ini.o k3fm_util.o \
k4ib_util.o k4label_util.o k4pcalports_util.o k4rec_mode_util.o k4rec_util.o \
k4recpatch_util.o k4st_util.o k4tape_util.o k4vc_util.o k4vcbw_util.o \
k4vcif_util.o k4vclo_util.o lba_cor_util.o lba_ft_util.o lba_ifp_util.o \
lba_mon_util.o lba_trkfrm_util.o lbaifpd.o lo_util.o lower.o lvdofn_v.o \
lvdonn_v.o m5_utils.o mcb_util.o mcbcn_v.o mcbcn_v2.o mk4bbcd.o mk4vcd.o \
mk5_status_util.o mk5b_mode_util.o mk5bbcd.o mk5dbbcd.o mk5dbbcd_pfb.o mk5vcd.o \
mk6_disk_pos_util.o mk6_scan_check_util.o motion_done.o mvdis_v.o mvupper.o \
nsem_util.o ntp_synch.o onoff_util.o pcald_util.o pcalform_util.o \
pcalports_util.o play_wav.o pps_source_util.o prog_exec.o rcl_util.o \
rclcn_req_util.o rclcn_res_util.o rdbcn_v.o rdbe_2_tsysx.o rdbe_atten_util.o \
rdbe_dot_util.o rec_mode_util.o req_util.o res_util.o rollform_util.o rp2code.o \
rp2codek41.o rp2codek42.o rvac_util.o rwff_v.o s2label_util.o s2rec_util.o \
s2st_util.o s2tape_util.o satellite_util.o satoff_util.o scan_check_util.o \
selectcmd_util.o sem_util.o semid_util.o setMK4FMrec.o set_k3aux.o set_vaux.o \
setup_ids.o shm_util.o sig_ignore.o skd_util.o str_util.o systracks_util.o \
tape_util.o tpi_dbbc.o tpi_dbbc3.o tpi_dbbc_pfb.o tpi_lba.o tpi_norack.o \
tpi_vlba.o tpicd_util.o tracks4_util.o tracks_util.o trkfrm4_util.o \
trkfrm_util.o user_device_util.o user_info_util.o v2_head_vmov.o \
v2_motion_done.o v2_vlt_head.o v_vlt_head.o vacuum.o venable_util.o vform_util.o \
vlbabbcd.o vrepro_util.o vset_zero.o vsi4_util.o vst_util.o wvolt_util.o

clib.a: $(OBJECTS)

include ../include.mk
