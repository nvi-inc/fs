#
CFLAGS= -g
LIBS = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = erchk.o get_err.o


ifeq "$(FS_DISPLAY_SERVER)" "no"  
	CPPFLAGS += -DNO_SERVER
endif

../bin/erchk: $(OBJECTS) $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

.PHONEY: erchk
erchk:
	rm -f ../bin/erchk
	make
