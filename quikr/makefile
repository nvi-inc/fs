#
all: ../bin/quika ../bin/quikb ../bin/quikc ../bin/quikd
#
F77= gf77
FFLAGS = -c -g
LIBES = ../boss/boss.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a\
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a\
../newlb/newlb.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a -lrtx
#
OBJECTSA = quika.o cable.o cadis.o cal.o chk.o devds.o\
et.o feet.o fm.o fmdis.o ib.o ickft.o ifd.o ifdis.o\
ma.o mvdis.o rwff.o setsp.o st.o stdis.o tp.o tpdis.o\
tppos.o vc.o vcdis.o wakop.o wx.o
#
../bin/quika: $(OBJECTSA)
	gf77 -g -o ../bin/quika $(OBJECTSA) $(LIBES)
	../setb/setb ../bin/quika
#
OBJECTSB = quikb.o aeoff.o ctemp.o de.o dedis.o ena.o\
endis.o gtrad.o label.o matld.o mezhr.o newtp.o onsor.o party.o\
pe.o pedis.o rdoff.o repds.o repro.o reset.o sorce.o\
tpi.o tplis.o tplisv.o tpput.o track.o tsys.o xyoff.o
#
../bin/quikb: $(OBJECTSB)
	gf77 -g -o ../bin/quikb $(OBJECTSB) $(LIBES)
	../setb/setb ../bin/quikb
#
OBJECTSC = quikc.o fpdis.o fsvrs.o fvpnt.o hdpos.o head.o\
hmove.o iphck.o ivc2t.o ivcat.o lgout.o lodis.o loset.o nfdis.o\
onofc.o oprid.o padis.o patch.o pc.o pcalc.o pcals.o pcdis.o\
rxdmo.o rxmo.o upset.o updis.o
#
../bin/quikc: $(OBJECTSC)
	gf77 -g -o ../bin/quikc $(OBJECTSC) $(LIBES)
	../setb/setb ../bin/quikc
#
OBJECTSD = quikd.o beam.o class_frm.o flux.o flxvl.o frmaux.o\
get_power.o gtrad.o hdata.o hdcalc.o head_d_mic.o head_move.o\
head_vlt.o hecho.o iw2ma.o lchd.o locate.o lvdt.o ma2uc.o\
mic2vlt.o mic_read.o pas2mic.o pass.o peak.o pkhd.o savev.o\
set_mic.o set_pass.o set_vlt.o stack.o tpform.o uc2ma.o ucdmo.o\
ucmo.o vlt_read.o wohd.o worm.o
#
../bin/quikd: $(OBJECTSD)
	gf77 -g -o ../bin/quikd $(OBJECTSD) $(LIBES)
	../setb/setb ../bin/quikd
#
quikb:
	rm -f ../bin/quikb
	make ../bin/quikb
#
quika:
	rm -f ../bin/quika
	make ../bin/quika
#
quikc:
	rm -f ../bin/quikc
	make ../bin/quikc
#
quikd:
	rm -f ../bin/quikd
	make ../bin/quikd
