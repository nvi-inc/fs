#
FFLAGS = -c
LIBES = ../bosslb/bosslb.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a\
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a\
../newlb/newlb.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a
#
OBJECTS = quikr.o aeoff.o beam.o cable.o cadis.o cal.o chk.o\
class_frm.o ctemp.o de.o dedis.o devds.o ena.o endis.o\
et.o feet.o flux.o flxvl.o fm.o fmdis.o form4.o\
fpdis.o frmaux.o frmaux4.o fsvrs.o fvpnt.o get_power.o gtrad.o\
hdata.o hdcalc.o head_d_mic.o head_move.o head_vlt.o\
hecho.o ib.o ickft.o if3.o if3dis.o ifd.o ifdis.o iphck.o\
ivc2t.o ivcat.o iw2ma.o label.o lchd.o lgout.o locate.o\
lodis.o loset.o lvdt.o ma.o matld.o mezhr.o\
mic2vlt.o mic_read.o mvdis.o newtp.o nfdis.o onofc.o onsor.o\
oprid.o padis.o party.o party4.o pas2mic.o pass.o patch.o\
pc.o pcalc.o pcals.o pcdis.o pe.o peak.o pedis.o\
pkhd.o rdoff.o repds.o repds4.o repro.o repro4.o\
reset.o rwff.o rxdmo.o rxmo.o savev.o set_mic.o set_pass.o\
set_vlt.o setsp.o sorce.o st.o stack.o stdis.o\
tp.o tpdis.o tpform.o tpi.o tplis.o tplisv.o tppos.o\
tpput.o track.o tsys.o\
updis.o upset.o vc.o vcdis.o vlt_read.o wakop.o wohd.o\
worm.o wx.o xyoff.o gtradd.o
#
../bin/quikr: $(OBJECTS)
	$(FC) -o ../bin/quikr $(OBJECTS) $(LIBES)
	strip ../bin/quikr
#
quikr:
	rm -f ../bin/quikr
	make ../bin/quikr
