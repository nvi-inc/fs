#
CFLAGS= 
LIBES = ../clib/clib.a ../rtelb/rtelb.a
#
OBJECTS =\
quikv.o dist.o dist_dis.o logmsg.o vrepro.o vrepro_dis.o vform.o vform_dis.o\
venable.o venable_dis.o dqa.o dqa_dis.o capture.o capture_dis.o bbc.o\
bbc_dis.o vst.o vst_dis.o rec.o rec_dec.o rec_dis.o tape.o tape_dis.o\
mcb.o mcb_dis.o vform_ver.o trkfrm.o trkfrm_dis.o tracks.o tracks_dis.o\
bit_density.o bit_density_dis.o systracks.o systracks_dis.o
#
../bin/quikv: $(OBJECTS)
	cc  -o ../bin/quikv $(OBJECTS) $(LIBES) -lm
	strip ../bin/quikv
#
quikv:
	rm -f ../bin/quikv
	make
