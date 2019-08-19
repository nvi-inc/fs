all: ../bin/monit1 ../bin/monit2 ../bin/monit3 ../bin/monit4 ../bin/monit5 ../bin/monit6

CPPFLAGS  +=  -I/usr/include/ncurses
LDLIBS += -lm -lncurses
ifdef FS_TINFO_LIB
	LDLIBS += -ltinfo
endif

LIBS = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a

OBJECTS1 = monit1.o die.o

../bin/monit1: $(OBJECTS1) $(LIBS)

OBJECTS2 = monit2.o die.o azel.o sider.o pre_str.o m2init.o\
		   mout2.o satpos.o

../bin/monit2: $(OBJECTS2) $(LIBS)

OBJECTS3 = monit3.o die.o pre_str.o

../bin/monit3: $(OBJECTS3) $(LIBS)

OBJECTS4 = monit4.o die4.o m4init.o mout4.o

../bin/monit4: $(OBJECTS4) $(LIBS)

OBJECTS5 = monit5.o die.o pre_str.o m5init.o\
		   mout5.o

../bin/monit5: $(OBJECTS5) $(LIBS)

OBJECTS6 = monit6.o die.o m6init.o mout6.o gmonit6.o

../bin/monit6: $(OBJECTS6) $(LIBS)

include ../include.mk
