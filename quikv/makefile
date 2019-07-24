#
CFLAGS= -g
LIBES = ../clib/clib.a ../rtelb/rtelb.a -lrtx
#
OBJECTS =\
quikv.o dist.o dist_dis.o logmsg.o vrepro.o vrepro_dis.o vform.o vform_dis.o\
venable.o venable_dis.o dqa.o dqa_dis.o capture.o capture_dis.o bbc.o\
bbc_dis.o vst.o vst_dis.o rec.o rec_dec.o rec_dis.o tape.o tape_dis.o\
mcb.o mcb_dis.o
#
../bin/quikv: $(OBJECTS)
	cc -g -o ../bin/quikv $(OBJECTS) $(LIBES) -lm
	../setb/setb ../bin/quikv
#
quikv:
	rm -f ../bin/quikv
	make
