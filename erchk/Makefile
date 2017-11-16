#
CFLAGS= -g
LIBS = ../poclb/poclb.a ../clib/clib.a ../rtelb/rtelb.a
OBJECTS = erchk.o get_err.o

ifdef FS_NO_DISPLAY_SERVER
CPPFLAGS += -DFS_NO_DISPLAY_SERVER
endif

../bin/erchk: $(OBJECTS) $(LIBS)
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

.PHONEY: erchk
erchk:
	rm -f ../bin/erchk
	make
