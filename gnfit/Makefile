LIBES = ../vis/vis.a ../clib/clib.a
OBJECTS= gnfit.o fit2.o  fpoly.o  scaler.o unscaler.o inine.o incne.o \
dppco.o dppfa.o dppin.o dppsl.o
#
FFLAGS = -c 
../bin/gnfit: $(OBJECTS)
	$(FC)  -o ../bin/gnfit $(OBJECTS) $(LIBES) -lm
	strip ../bin/gnfit

gnfit:
	rm -f ../bin/gnfit
	make
#
