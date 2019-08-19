# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#
ifdef NO_FTOK_FS
CFLAGS +=  -DNO_FTOK_FS
endif
LIBS = ../clib/clib.a ../rtelb/rtelb.a

class: class.o  $(LIBS)
class2: class2.o $(LIBS)
class3: class3.o $(LIBS)
class4: class4.o $(LIBS)

