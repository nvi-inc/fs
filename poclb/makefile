# Makefile for library routines
#
OBJECTS = pname.o logit.o iadt.o equn.o\
gmodl.o pmdlq.o sider.o refrw.o cnvrt.o limit.o flt.o fln.o echoe.o logita.o\
logite.o
#
poclb.a: $(OBJECTS)
	touch poclb.a
	rm poclb.a
	ar -qc poclb.a $(OBJECTS)
	ar s poclb.a
