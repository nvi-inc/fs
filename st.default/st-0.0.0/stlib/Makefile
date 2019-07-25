# Makefile for library routines
#
OBJECTS = setup_st.o stm_util.o
#
stlib.a: $(OBJECTS)
	touch stlib.a
	rm stlib.a
	ar -qc stlib.a $(OBJECTS)
	ar -s stlib.a
