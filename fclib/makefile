#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
fc_rte_alarm.o fc_cls_clr.o fc_exit.o fc_incom_ini.o fc_prog_exec.o\
fc_setup_ids.o fc_shm_map.o fc_shm_read.o fc_shm_write.o fc_skd_run.o\
fc_skd_wait.o fc_rte_sleep.o\
fc_rte_time.o\
fc_cls_rcv.o fc_cls_snd.o fc_skd_par.o fc_loc_map.o\
fc_loc_read.o fc_loc_write.o fc_setup_st.o fc_dad_pid.o\
fc_nsem_take.o fc_nsem_test.o fc_nsem_put.o fc_system.o fc_brk_chk.o\
fc_brk_snd.o fc_skd_clr.o fc_get_vatod.o fc_lvdofn_v.o fc_lvdonn_v.o\
fc_head_vmov.o fc_mcbcn_v.o fc_vset_zero.o fc_mcbcn_v2.o\
fc_tpi_vlba.o fc_et_v.o fc_rwff_v.o fc_get_vaux.o fc_set_vaux.o\
fc_chmod.o fc_rte_lock.o fc_rte_prior.o fc_putln.o fc_get_vtime.o\
fc_mvdis_v.o fc_bbc2freq.o fc_rte_sett.o fc_rte2secs.o fc_rte_rawt.o\
fc_rte_fixt.o fc_cls_sndc.o fc_secs2rte.o fc_skd_arg.o fc_go_take.o\
fc_go_put.o fc_v2_vlt_head.o fc_v2_head_vmov.o fc_cshm_init.o fc_get_s2time.o\
fc_putpname.o fc_get_k3time.o fc_set_k3aux.o fc_get_k4time.o\
fc_dqa4_cnvrt.o fc_tpi_norack.o fc_mk4vcd.o fc_skd_end_insnp.o fc_vlbabbcd.o\
fc_mk4bbcd.o fc_get_rxgain_files.o fc_get_flux_file.o fc_get_tcal_fwhm.o \
fc_lbaifpd.o fc_tpi_lba.o fc_dscon_v.o fc_ntp_synch.o fc_rte_cmpt.o\
fc_rte_ticks.o fc_readlink.o fc_perror.o fc_mk5vcd.o fc_mk5bbcd.o\
fc_get_5btime.o fc_play_wav.o fc_rte_check.o fc_putln2.o fc_mk5dbbcd.o\
fc_tpi_dbbc.o fc_dbbcn_v.o fc_get_fila10gtime.o fc_antcn_term.o\
fc_mk5dbbcd_pfb.o fc_tpi_dbbc_pfb.o fc_dbbcn_pfb_v.o fc_if_cmd.o
#
#CFLAGS = 
#FFLAGS = 
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
fclib.a: $(OBJECTS)
	touch fclib.a
	rm fclib.a
	ar -qc fclib.a $(OBJECTS)
	ar s fclib.a
