#
#  Note that the backslash character has been used at the end of each line
#  to indicate continuation.
#
OBJECTS=\
get_buf.o put_buf.o read_fscom.o read_init.o put_buf_ch.o\
read_quikr.o run_prog.o setup_fscom.o wait_prog.o write_fscom.o\
write_init.o write_quikr.o clrcl.o wait_relt.o\
wait_abst.o susp.o rmpar.o rn_take.o rn_put.o rn_test.o kbreak.o\
send_break.o clear_prog.o wait_abstd.o put_bufi.o get_arg.o\
suspend.o go_suspend.o
#
#CFLAGS = 
#FFLAGS = 
F77 = gf77
#
#  The following line that has a ":" in it is a "dependency line".
#  What follows the dependency line are command lines.  The
#  one with the library name, fclib, before the ":" is the name of the
#  program to be built.  The modules that are referred to afcer the ":"
#  list what that program is dependent on.  References to variables are
#  signalled by a leading "$" character.
#
flib.a: $(OBJECTS)
	touch flib.a
	rm flib.a
	ar -qc flib.a $(OBJECTS)
	ar s flib.a
