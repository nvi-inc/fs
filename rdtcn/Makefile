LIBS = ../poclb/poclb.a ../clib/clib.a ../poclb/poclb.a ../rtelb/rtelb.a -lm
OBJECTS = rdtcn.o r1dbe.o r2dbe.o FFT.o rdbe_freqz.o rt_nonfinite.o rtGetInf.o\
					rtGetNaN.o open_mcast.o read_mcast.o get_if_addr.o packet_r2dbe_unpack.o\
					calc_ts.o calc_pc.o update_shm.o

../bin/rdtcn: $(OBJECTS) $(LIBS)

include ../include.mk
