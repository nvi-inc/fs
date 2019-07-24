# Makefile for library routines
#
LIBES = ../../fs/clib/clib.a ../../fs/rtelb/rtelb.a
OBJECTS = pname.o logit.o iadt.o setup_st.o loc_util.o
#
stlib.a: $(OBJECTS)
	touch stlib.a
	rm stlib.a
	ar qc stlib.a $(OBJECTS)
