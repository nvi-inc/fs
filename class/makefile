# set environment variable NO_FTOK_FS non-empty if ftok() is not available
# if you use csh/tcsh add this to your .login file:
#   setenv NO_FTOK_FS TRUE
# and log-out and back in
#
ifdef NO_FTOK_FS
CFLAGS :=  -DNO_FTOK_FS
endif
LIBES = ../clib/clib.a ../rtelb/rtelb.a
#
class: class.o $(OBJECTS)
	cc  -o class class.o $(OBJECTS) $(LIBES)
	strip class
#
class2: class2.o $(OBJECTS)
	cc  -o class2 class2.o $(OBJECTS) $(LIBES)
	strip class2
#
class3: class3.o $(OBJECTS)
	cc  -o class3 class3.o $(OBJECTS) $(LIBES)
	strip class4
#
class4: class4.o $(OBJECTS)
	cc  -o class4 class4.o $(OBJECTS) $(LIBES)
	strip class4
#
