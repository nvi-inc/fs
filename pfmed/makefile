# 010709 pb - added sortp,scanp,sortq. 
# 010904 pb - gnue 'readline' mods. 
OBJECTS = \
pfmed.o fed.o ffm.o ffmp.o fnblnk.o kerr.o pfblk.o \
pfcop.o pfmbd.o purn.o reprc.o ftn_edit.o sortp.o\
scanp.o sortq.o readpl.o ldsrt.o follow_link.o
#
LIBES = ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a\
 ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a
ifeq (../oprin/readline-2.0,$(wildcard ../oprin/readline-2.0))
LIBES := $(LIBES) ../oprin/readline-2.0/libreadline.a
CFLAGS = -I../oprin/readline-2.0 -DREADLINE
else
LIBES := $(LIBES) -lreadline
READLINE :=$(shell fgrep >/dev/null 2>&1 'rl_compentry_func_t' /usr/include/readline/readline.h ; echo $$?)
ifneq ($(READLINE),0)
$(error ../oprin/readline-2.0 does not exist, but system readline is incorrect version, make oprin first)
endif
endif
#
TERMLIB = -lncurses
ifeq (/usr/lib/libtermcap.a,$(wildcard /usr/lib/libtermcap.a))
TERMLIB = -ltermcap
endif

#
../bin/pfmed: $(OBJECTS) $(LIBES)
	$(FC)  -o ../bin/pfmed $(OBJECTS) $(LIBES) $(TERMLIB)
	strip ../bin/pfmed
#
pfmed:
	rm -f ../bin/pfmed
	make
