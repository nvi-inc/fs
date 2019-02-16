LIBS = ../bosslb/bosslb.a ../polb/polb.a ../fslb/fslb.a ../lnfch/lnfch.a\
../newlb/newlb.a ../flib/flib.a ../fclib/fclib.a ../clib/clib.a\
../poclb/poclb.a ../newlb/newlb.a ../fmpsee/fmpsee.a ../rtelb/rtelb.a

OBJECTS = quikr.o aeoff.o cable.o cadis.o cal.o chk.o\
class_frm.o de.o dedis.o devds.o ena.o endis.o\
et.o fm.o fmdis.o form4.o\
fpdis.o frmaux.o frmaux4.o fsvrs.o fvpnt.o get_power.o gtrad.o\
hdata.o hdcalc.o head_d_mic.o head_move.o head_vlt.o\
hecho.o ib.o if3.o if3dis.o ifd.o ifdis.o iphck.o\
ivc2t.o ivcat.o iw2ma.o label.o lchd.o lgout.o locate.o\
lvdt.o ma.o matld.o mezhr.o\
mic2vlt.o mic_read.o mvdis.o newtp.o onsor.o\
oprid.o padis.o party.o pas2mic.o pass.o patch.o\
pc.o pcalc.o pcals.o pcdis.o pe.o peak.o pedis.o\
pkhd.o rdoff.o repds.o repds4.o repro.o repro4.o\
reset.o rwff.o rxdmo.o rxmo.o savev.o set_mic.o set_pass.o\
set_vlt.o sorce.o st.o stack.o stdis.o\
tp.o tpdis.o tpform.o tpi.o tplis.o tplisv.o tppos.o\
tpput.o track.o tsys.o\
vc.o vcdis.o vlt_read.o wakop.o wohd.o\
worm.o wx.o xyoff.o gtradd.o rec.o recds.o\
tplisn.o get_att.o get_at3.o tplisl.o tplisd.o tplisd3.o

LDLIBS += $(FLIBS)

../bin/quikr: $(OBJECTS) $(LIBS)

include ../include.mk
