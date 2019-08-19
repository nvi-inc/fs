# 010709 pb - added sortp,scanp,sortq. 
# 010904 pb - gnue 'readline' mods. 
OBJECTS = \
pfmed.o fed.o ffm.o ffmp.o fnblnk.o kerr.o pfblk.o \
pfcop.o pfmbd.o purn.o reprc.o ftn_edit.o sortp.o\
scanp.o sortq.o readpl.o ldsrt.o follow_link.o
#
LIBS = ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a\
 ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a

LDLIBS += -lreadline

TERMLIB = -lncurses
ifeq (/usr/lib/libtermcap.a,$(wildcard /usr/lib/libtermcap.a))
TERMLIB = -ltermcap
endif

LDLIBS += $(TERMLIB)
LDLIBS += $(FLIBS)

../bin/pfmed: $(OBJECTS) $(LIBS)

include ../include.mk
