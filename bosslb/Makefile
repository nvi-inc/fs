#
OBJECTS=\
gtnam.o gttim.o kpast.o krcur.o kstak.o prget.o prpop.o prput.o\
readg.o readp.o reads.o reftm.o tmlis.o twrap.o
#
bosslb.a: $(OBJECTS)
	touch bosslb.a
	rm bosslb.a
	ar -qc bosslb.a $(OBJECTS)
	ar s bosslb.a