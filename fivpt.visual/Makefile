OBJECTS = fivpt.o antcn.o dpoin.o errot.o fgaus.o fit2.o \
fitot.o fivp.o gooff.o jr2as.o local.o matcn.o matin.o \
offco.o offot.o onsor.o orign.o prfot.o reoff.o scmds.o \
site.o sorce.o tsys.o unslp.o volts.o wtsys.o mcbcn.o xoffot.o \
fivptplt.o
#
#FFLAGS = -c  -i2
FFLAGS = -c 
#FFLAGS = -c -cpp
# g77 compiler is not standard for field system, but need for lpgplot.
FC = /usr/bin/g77
LIBES = ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a ../newlb/newlb.a \
../flib/flib.a ../fclib/fclib.a ../clib/clib.a ../fmpsee/fmpsee.a \
../port/port.a ../rtelb/rtelb.a
#
# for FS Linux 5 you must have packages pgplot5, libpng2-dev, xlibs-dev
# installed, if they aren't, then (for missing packages) as root:
#   apt-get install pgplot5 libpng2-dev xlibs-dev
#
# set environment variable PRE_FS_LINUX_5 non-empty for (some) distributions
# before FS Linux 5, if you use csh/tcsh add this to your .login file:
#   setenv PRE_FS_LINUX_5 TRUE
# and log-out and back in
#
ifdef PRE_FS_LINUX_5
LIBFLAGS = -L/usr/X11R6/lib -lX11 -lpgplot
else
LIBFLAGS = -lpgplot -L/usr/X11R6/lib -lX11 -lpng -lz -lm
endif
#
../bin/fivpt: $(OBJECTS)
	$(FC)  -o ../bin/fivpt $(OBJECTS) $(LIBES) $(LIBFLAGS)
	strip ../bin/fivpt
#
fivpt:
	rm -f ../bin/fivpt
	make
