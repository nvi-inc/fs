#
CFLAGS= 
LIBES = ../clib/clib.a ../rtelb/rtelb.a ../poclb/poclb.a ../rtelb/rtelb.a
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
logmatmsgfm.o
#
../bin/quikv: $(OBJECTS)
	cc  -o ../bin/quikv $(OBJECTS) $(LIBES) -lm
	strip ../bin/quikv
#
quikv:
	rm -f ../bin/quikv
	make
