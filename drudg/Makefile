#######################################################################
#                                                                     #
#                         makefile for DRUDG                          #
#                            HP 9000/7xx                              #
#                     NRV      950824                                 #
#                                                                     #
#                                                                     #
#######################################################################
#
# Set paths
#

SRCDIR=../

DR = $(SRCDIR)drudg/
UT = $(SRCDIR)skdrut/
IN = $(SRCDIR)include/
PROGRAM = drudg

#
# Set objects
#
DROBS=\
$(DR)ckobs.o $(DR)clist.o $(DR)crprc.o $(DR)drudg.o $(DR)gtsnp.o \
$(DR)knewt.o $(DR)lists.o $(DR)lspin.o $(DR)m3inf.o $(DR)point.o \
$(DR)procs.o $(DR)snap.o  $(DR)sread.o $(DR)tmadd.o $(DR)tmsub.o \
$(DR)unpsk.o $(DR)drcom.o $(DR)fdrudg.o $(DR)trkall.o $(DR)spdstr.o \
$(DR)setba_dr.o $(DR)wrdur.o $(DR)wrtap.o $(DR)dsnout.o \
$(DR)label.o $(DR)blabl.o $(DR)wrtrack.o $(DR)wrbbsyn.o $(DR)wrhead.o \
$(DR)cmshf.o $(DR)tshft.o $(DR)getqual.o $(DR)bbsyn.o \
$(DR)skdshft.o $(DR)snpshft.o $(DR)luff.o $(DR)cbinf.o $(DR)bcode.o \
$(DR)snapintr.o $(DR)bbbuf.o $(DR)cazel.o $(DR)gtshft.o $(DR)bar1.o \
$(DR)labsnp.o $(DR)port.o $(DR)lstsum.o $(DR)nhdif.o $(DR)setprint.o \
$(DR)shfcop.o $(DR)getstr.o $(DR)prtmp.o $(DR)wrdate.o \
$(DR)b3of9.o

#
# Set compiling and linking flags
#
# -I2 makes 2 bytes the default size for INTEGER and LOGICAL types.
# -g is for debugging
# -C checks for out of bounds during execution and aborts if found
#FFLAGS=-C -c -g -I2 -I$(IN)
FFLAGS= -C -c -I$(IN)
CFLAGS= -c  
#

#
LDFLAGS=../skdrut/skdrut.a ../lnfch/lnfch.a ../fslb/fslb.a ../newlb/newlb.a
#
../bin/$(PROGRAM): $(DROBS) 
	rm -f ./core
	@echo Linking $(PROGRAM)...
	@f77 -o ../bin/$(PROGRAM) $(DROBS) $(LDFLAGS)
	@strip ../bin/$(PROGRAM)
	@echo done.

#  The following are special dependency lines for compiling.

.f.o:
	cd $(<D); f77 $(FFLAGS) $<
.c.o:
	cd $(<D); cc $(CFLAGS) $<


