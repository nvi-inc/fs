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
mcb_util.o bblv2db.o motion_done.o itrk2bbc.o mvdis_v.o vacuum.o semid_util.o\
go_util.o get_vatod.o v2_head_vmov.o v2_motion_done.o v2_vlt_head.o
#
CFLAGS = 
#FFLAGS = 
F77 = gf77
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
