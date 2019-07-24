c fscom_dum.i
c
c See fscom.i for information on the structure
c
      double precision ra50, dec50, radat, decdat, alat, wlong

      REAL AZOFF, DECOFF, ELOFF, ISTPTP, ITACTP, RAOFF,
     . XOFF, YOFF, ep1950, tempwx, preswx, humiwx,
     . cablev, systmp(30), epoch, height, diaman, slew1, slew2,
     . lolim1, lolim2, uplim1, uplim2,
     . HORAZ(MAX_HOR), HOREL(MAX_HOR), motorv, inscint, inscsl, 
     . outscint, outscsl, wrvolt, rxvfac(MAX_RXCODES), 
     . rxvoff(MAX_RXCODES) 

      integer*4 iclbox, iclopr, time_offset(2)

      logical khalt, kecho, kenastk(2), klvdt_fs

      INTEGER ICAPTP, ICHECK(20), ILOKVC(15), 
     . IRDYTP, IRENVC, ITRAKA, ITRAKB, TPIVC(15), ibmat, ibmcb,
     . ionsor, ipashd(2), ispeed, iremtp, ienatp,
     . idirtp, imodfm, iratfm, inp1if, inp2if, ndevlog, iaxis(2),
     . rack, drive, imaxtpsd, ichvlba(20), iskdtpsd, itpthick,
     . time_index, vform_rate, vgroup(4), capstan

      INTEGER*2 ILEXPER(4), ILLOG(4), ILNEWPR(4), ILNEWSK(4),
     . ILPRC(4), ILSKD(4), ILSTP(4), INEXT(3), LFEET_FS(3), lgen(2),
     . lnaant(4), lsorna(5), lfreqv(3,15), idevant(32), idevgpib(32),
     . idevlog(5,32), idevmcb(32), hwid, rxlcode(3,MAX_RXCODES), 
     . rxncodes

      common/fscom_dum/
     . ra50, dec50, radat, decdat, alat, wlong,
     . AZOFF, DECOFF, ELOFF, ISTPTP, ITACTP, RAOFF,
     . XOFF, YOFF, ep1950, tempwx, preswx, humiwx,
     . cablev, systmp, epoch, height, diaman, slew1, slew2,
     . lolim1, lolim2, uplim1, uplim2,
     . HORAZ, HOREL, motorv, inscint, inscsl, outscint,
     . outscsl, wrvolt, rxvfac, rxvoff,
     . iclbox, iclopr, time_offset,
     . khalt, kecho, kenastk, klvdt_fs,
     . ICAPTP, ICHECK, ILOKVC, IRDYTP, 
     . IRENVC, ITRAKA, ITRAKB, TPIVC, ibmat, ibmcb,
     . ionsor, ipashd, ispeed, iremtp, ienatp,
     . idirtp, imodfm, iratfm, inp1if, inp2if, ndevlog, iaxis,
     . rack, drive, imaxtpsd, ichvlba, iskdtpsd,
     . itpthick, time_index,
     . vform_rate, vgroup, capstan,
     . ILEXPER, ILLOG, ILNEWPR, ILNEWSK,
     . ILPRC, ILSKD, ILSTP, INEXT, LFEET_FS, lgen, lnaant, lsorna, 
     . lfreqv, idevant, idevgpib, idevlog, idevmcb, hwid, 
     . rxlcode, rxncodes


      CHARACTER*8 LEXPER, LLOG, LNEWPR, LNEWSK, LPRC, LSKD, LSTP

      common/fscom_dum2/ LEXPER, LLOG, LNEWPR, LNEWSK, LPRC, LSKD, LSTP

