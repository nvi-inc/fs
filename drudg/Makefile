#######################################################################
#                                                                     #
#                         makefile for DRUDG                          #
# 960201 nrv for Linux                                                #
# 960602 nrv with vex libraries                                       #
# 970312 nrv Add read_snap1                                           #
# 970319 nrv Move knewt to skdrut                                     #
# 970401 nrv Add DRSET                                                #
# 970406 nrv Move c2upper to skdrut                                   #
# 970509 nrv Add WRSOR                                                #
# 970603 nrv Add PRCOV                                                #
# 971211 nrv Add IADDPC                                               #
# 980910 nrv Add TIMOUT                                               #
# 980916 nrv Add PRTXT                                                #
# 980916 nrv Add TIMOUT                                               #
# 980929 nrv Add K4TYPE                                               #
#                                                                     #
#######################################################################

all: ../bin/drudg ../bin/ifvlbafix

#
# Set paths
#

SRCDIR=../

DR = $(SRCDIR)drudg/
UT = $(SRCDIR)skdrut/
PROGRAM = drudg

#
# Set objects
#
DROBS=\
$(DR)drudg.o \
$(DR)ckobs.o $(DR)clist.o $(DR)crprc.o  $(DR)gtsnp.o \
$(DR)knewt.o $(DR)lists.o $(DR)lspin.o $(DR)m3inf.o $(DR)point.o \
$(DR)procs.o $(DR)snap.o  $(DR)sread.o $(DR)tmadd.o $(DR)tmsub.o \
$(DR)unpsk.o $(DR)fdrudg.o $(DR)trkall.o $(DR)spdstr.o \
$(DR)setba_dr.o $(DR)wrdur.o $(DR)wrtap.o $(DR)dsnout.o $(DR)iaddtr.o \
$(DR)label.o $(DR)blabl.o $(DR)wrtrack.o $(DR)wrbbsyn.o $(DR)wrhead.o \
$(DR)cmshf.o $(DR)tshft.o $(DR)getqual.o $(DR)bbsyn.o \
$(DR)skdshft.o $(DR)snpshft.o $(DR)luff.o $(DR)cbinf.o $(DR)bcode.o \
$(DR)snapintr.o $(DR)bbbuf.o $(DR)cazel.o $(DR)gtshft.o $(DR)bar1.o \
$(DR)labsnp.o $(DR)port.o $(DR)lstsum.o $(DR)nhdif.o $(DR)setprint.o \
$(DR)shfcop.o $(DR)getstr.o $(DR)prtmp.o $(DR)wrdate.o \
$(DR)b3of9.o $(DR)drchmod.o $(DR)vlbat.o $(DR)vlbah.o \
$(DR)lstsumo.o $(DR)isecdif.o $(DR)psbar.o $(DR)copen.o $(DR)procintr.o \
$(DR)read_snap1.o $(DR)drset.o $(DR)wrsor.o $(DR)prcov.o $(DR)iaddpc.o \
$(DR)timin.o $(DR)timout.o $(DR)prtxt.o $(DR)k4type.o

#
# Set compiling and linking flags
#
# -C checks for out of bounds during execution and aborts if found
FFLAGS= -C -c 
# f2c needs this others don't
CFLAGS= -c  -DF2C
#

#
LIBS=$(UT)skdrut.a ../lnfch/lnfch.a ../fslb/fslb.a \
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a \
../vex/vex.a -lf2c -lfl
#
../bin/$(PROGRAM): $(DROBS) 
	rm -f ./core
	@echo Linking $(PROGRAM)...
	@$(FC) -o ../bin/$(PROGRAM) $(DROBS) $(LIBS)
	@strip ../bin/$(PROGRAM)
	@echo done.

../bin/ifvlbafix: ifvlbafix
	rm -f ../bin/ifvlbafix
	ln -s ../drudg/ifvlbafix ../bin/ifvlbafix

#  The following are special dependency lines for compiling.

.f.o:
	cd $(<D); $(FC) $(FFLAGS) $<
.c.o:
	cd $(<D); cc $(CFLAGS) $<


