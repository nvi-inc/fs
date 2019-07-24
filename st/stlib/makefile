# Makefile for library routines
#
LIBES =  ../../fs/rtelb/rtelb.a
OBJECTS = setup_st.o pname.o logit.o iadt.o stm_util.o equn.o \
gmodl.o pmdlq.o sider.o refrw.o cnvrt.o limit.o flt.o fln.o
#
stlib.a: $(OBJECTS)
	touch stlib.a
	rm stlib.a
	ar qc stlib.a $(OBJECTS)
