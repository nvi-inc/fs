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
selectcmd_util.o rollform_util.o
#
CFLAGS = 
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
