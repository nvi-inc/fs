#
CFLAGS= 
LIBES = ../clib/clib.a ../rtelb/rtelb.a ../s2das/s2das.a ../poclb/poclb.a\
../newlb/newlb.a
#
OBJECTS =\
quikv.o dist.o dist_dis.o logmsg.o vrepro.o vrepro_dis.o vform.o vform_dis.o\
venable.o venable_dis.o dqa.o dqa_dis.o capture.o capture_dis.o bbc.o\
bbc_dis.o vst.o vst_dis.o rec.o rec_dec.o rec_dis.o tape.o tape_dis.o\
mcb.o mcb_dis.o vform_ver.o trkfrm.o trkfrm_dis.o tracks.o tracks_dis.o\
bit_density.o bit_density_dis.o systracks.o systracks_dis.o rcl.o rcl_dis.o\
user_info.o user_info_dis.o logrclmsg.o s2st.o s2st_dis.o s2et.o s2tape.o\
s2tape_dis.o rec_mode.o rec_mode_dis.o data_valid.o data_valid_dis.o\
s2label.o s2label_dis.o s2rec.o s2rec_dis.o get_s2speed.o get_s2state.o\
get_s2tapetype.o form4.o form4_dis.o logmatmsg.o tracks4.o tracks4_dis.o\
trkfrm4.o trkfrm4_dis.o rvac.o rvac_dis.o wvolt.o wvolt_dis.o lo.o lo_dis.o\
pcalform.o pcalform_dis.o pcald.o pcald_dis.o pcalports.o pcalports_dis.o\
save_file.o\
k4ib.o k4ib_dis.o k4et.o k4st.o k4st_dis.o k4tape.o k4tape_dis.o k4rec.o\
k4rec_dis.o k4vclo.o k4vclo_dis.o k4vc.o k4vc_dis.o k4vcif.o k4vcif_dis.o\
k4vcbw.o k4vcbw_dis.o k3fm.o k3fm_dis.o k4label.o k4label_dis.o k4newtp.o\
k4oldtp.o k4rec_mode.o k4rec_mode_dis.o logmatmsgfm.o k4recpatch.o\
k4recpatch_dis.o k4pcalports.o k4pcalports_dis.o selectcmd.o\
selectcmd_dis.o scan_name.o ifadjust.o get_att.o set_vc_sb.o get_itp.o\
reset_vc.o set_att.o tacd.o tacd_dis.o cablediff.o mk5.o mk5_dis.o\
disk_record.o disk_record_dis.o\
disk_pos.o disk_pos_dis.o disk_serial.o disk_serial_dis.o\
data_check.o data_check_dis.o data_check_pos.o mk5relink.o mk5close.o\
rollform.o rollform_dis.o tpicd.o tpicd_dis.o onoff.o onoff_dis.o\
calrx_dis.o ds.o ds_dis.o lba_cor.o lba_cor_dis.o lba_ft.o lba_ft_dis.o\
lba_ifp.o lba_ifp_dis.o lba_mon.o lba_mon_dis.o lba_trkfrm.o lba_trkfrm_dis.o\
bank_check.o bank_check_dis.o logm5msg.o disk2file.o disk2file_dis.o\
in2net.o in2net_dis.o user_device.o user_device_dis.o\
s2agc.o s2bbc.o s2diag.o s2encode.o s2fs.o s2ifx.o s2version.o s2mode.o\
s2ping.o s2pwrmon.o s2status.o s2tonedet.o s2chkr.o s2delay.o\
scan_check.o scan_check_dis.o last_check.o mk5b_mode.o mk5b_mode_dis.o mk5_status.o\
vsi4.o vsi4_dis.o holog.o holog_dis.o satellite.o satellite_dis.o antcn.o\
satoff.o satoff_dis.o satpos.o tle.o dbbc.o dbbc_dis.o dbbcnn.o dbbcnn_dis.o\
logmsg_dbbc.o dbbcifx.o dbbcifx_dis.o dbbcform.o dbbcform_dis.o\
dbbc_cont_cal.o dbbc_cont_cal_dis.o dbbcgain.o dbbcgain_dis.o\
fila10g_mode.o fila10g_mode_dis.o
#
../bin/quikv: $(OBJECTS)
	cc $(CFLAGS)  -o ../bin/quikv $(OBJECTS) $(LIBES) -lm
	strip ../bin/quikv
#
quikv:
	rm -f ../bin/quikv
	make

