# 010709 pb - added sortp,scanp,sortq. 
# 010904 pb - gnue 'readline' mods. 
OBJECTS = \
pfmed.o fed.o ffm.o ffmp.o fnblnk.o kerr.o pfblk.o \
pfcop.o pfmbd.o purn.o reprc.o ftn_edit.o sortp.o\
scanp.o sortq.o readpl.o ldsrt.o follow_link.o
#
CFLAGS = -I../oprin/readline-2.0
LIBES = ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a ../flib/flib.a\
 ../fclib/fclib.a ../clib/clib.a ../rtelb/rtelb.a\
 ../oprin/readline-2.0/libreadline.a
#
TERMLIB = -lncurses
ifeq (/usr/lib/libtermcap.a,$(wildcard /usr/lib/libtermcap.a))
TERMLIB = -ltermcap
endif

#
../bin/pfmed: $(OBJECTS) $(LIBS)
	$(FC)  -o ../bin/pfmed $(OBJECTS) $(LIBES) $(TERMLIB)
	strip ../bin/pfmed
#
pfmed:
	rm -f ../bin/pfmed
	make
