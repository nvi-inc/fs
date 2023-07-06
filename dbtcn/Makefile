LIBS = ../clib/clib.a ../poclb/poclb.a ../rtelb/rtelb.a -lm
OBJECTS = dbtcn.o open_mcast.o get_if_addr.o read_mcast.o log_mcast.o\
          packet_unpack.o calc_ts.o update_shm.o version_check.o\
          perform_swaps.o smooth_ts.o time_check.o

../bin/dbtcn: $(OBJECTS) $(LIBS) -lm

include ../include.mk
