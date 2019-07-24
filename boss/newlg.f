      subroutine newlg(ibuf,lsor)
C
C     NEWLG fills in the buffer with the first line of the log file
C           and sends this to DDOUT for starting a new log.
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
C  INPUT:
C
      integer*2 ibuf(1)
C      - buffer to use, assumed to be at least 50 characters long
      integer*2 ib(60)
      integer*2 lprocdumm(6)
C     LSOR - source of this message
C
C  OUTPUT: NONE
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  NRV  830914  Added occupation serial # as second buffer
C  LAR  880205  Added FSUPDATE call.
C  LAR  880331  Added 2nd line with minor version #
C  WEH  880708  REMOVE FSUPDATE CALL
C  gag  920902  Changed code to use pi from the include file dpi.i
C
C  LOCAL
      integer itsp(8)
      data itsp/0,3,7,15,30,60,120,240/
C
C     The new-log information line:
C   MARK IV FIELD SYSTEM VERSION <version> <station> <year> <occup#>
C     Send this with option "NL" to LOGIT, i.e. start new log file.
C
      call ifill_ch(ibuf,3,60,' ')
      nch = ichmv(ibuf,1,32H" MARK IV Field System Version   ,1,32)
      nch = nch + ir2as(int(fsver*10.+.001)/10.,ibuf,nch,3,1)
      call fs_get_lnaant(lnaant)
      nch = ichmv(ibuf,nch+1,lnaant,1,8)
      nch = nch+1
      nch = nch+ ib2as(iyear,ibuf,nch,4)
      nch = ichmv(ibuf,nch+1,loccup,1,8)-3
      call char2hol('nl',nl,1,2)
      call ifill_ch(lprocdumm,1,12,' ')
      call logit5(ibuf(2),nch,lsor,lprocdumm,nl)
C
C     Second line contains minor version #; not read by correlator
C     Send this as a normal message (i.e. NOT a new log)
C
      nch = 32 + ir2as(fsver,ibuf,33,4,2)
      call logit3(ibuf,nch,lsor)
C
C     Send configuration info from control files to log
C
      call ifill_ch(ib,1,120,' ')
      nch = 1
      nch=ichmv(ib,nch,8Hlocation,1,8)
      nch=mcoma(ib,nch)
      nch=ichmv(ib,nch,lnaant,1,8)
      nch=mcoma(ib,nch)
      nch=ichmv(ib,nch,lidstn,1,1)
      nch=mcoma(ib,nch)
      call fs_get_wlong(wlong)
      call fs_get_alat(alat)
      wl = wlong * 180.0D0/dpi
      al = alat * 180.0D0/dpi
      nch = nch + ir2as(wl,ib,nch,7,2)
      nch=mcoma(ib,nch)
      nch = nch + ir2as(al,ib,nch,6,2)
      nch=mcoma(ib,nch)
      call fs_get_height(height)
      nch = nch + ir2as(height,ib,nch,6,1)
      nch=mcoma(ib,nch)
      nch = ichmv(ib,nch,loccup,1,8)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(iacttp,ib,nch,o'100000'+6)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(i20kch,ib,nch,o'100000'+6)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(i70kch,ib,nch,o'100000'+6)
      nch=mcoma(ib,nch)
      nch = nch + ib2as(iyrctl_fs,ib,nch,o'100000'+6)
      nch=nch-1
      call logit3(ib,nch,lsor)
      call ifill_ch(ib,1,120,' ')
      nch = 1
      nch = ichmv(ib,nch,8Hhorizon1,1,8)
      nch = mcoma(ib,nch)
      call fs_get_horaz(horaz)
      call fs_get_horel(horel)
      do i=1,8
        if(horaz(i).lt.0) goto 400
        nch = nch + ir2as(horaz(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
        if(horel(i).lt.0) goto 400
        nch = nch + ir2as(horel(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
      enddo
400   nch = nch-2
      call logit3(ib,nch,lsor)
      call ifill_ch(ib,1,120,' ')
      nch = 1
      nch = ichmv(ib,nch,8Hhorizon2,1,8)
      nch = mcoma(ib,nch)
      do i=9,15
        if(horaz(i).lt.0) goto 500
        nch = nch + ir2as(horaz(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
        if(horel(i).lt.0) goto 500
        nch = nch + ir2as(horel(i),ib,nch,4,0)
        nch=mcoma(ib,nch)
      enddo
500   nch = nch-2
      if(nch.gt.8) call logit3(ib,nch,lsor)
C
      nch = 1
      nch = ichmv(ib,nch,6Hhead0,,1,6)
      do i=1,4
        if (i.eq.1) then
          idum=wrhd_fs
        else if(i.eq.2) then
          idum=rdhd_fs
        else if(i.eq.3) then
          idum=rpro_fs
        else
          idum=rpdt_fs
        endif
        if(idum.eq.0) then
          nch=ichmv(ib,nch,4Hall ,1,3)
        else if(idum.eq.1) then
          nch=ichmv(ib,nch,4Hodd ,1,3)
        else if(idum.eq.2) then ! no else so illegal value is blank
          nch=ichmv(ib,nch,4Heven,1,4)
        endif
        nch=mcoma(ib,nch)
      enddo
      if(kadapt_fs) then
        nch=ichmv(ib,nch,8Hadaptive,1,8)
      else
        nch=ichmv(ib,nch,6Hfixed ,1,5)
      endif
      nch=mcoma(ib,nch)
      if(kiwslw_fs) then
        nch=ichmv(ib,nch,4Hyes ,1,3)
      else
        nch=ichmv(ib,nch,2Hno  ,1,2)
      endif
      nch=mcoma(ib,nch)
      nch=nch+ir2as(lvbosc_fs,ib,nch,6,4)
      nch=mcoma(ib,nch)
      nch=nch+ib2as(ilvtl_fs,ib,nch,o'100000'+5)
      nch=nch-1
      call logit3(ib,nch,lsor)
C
      do i=1,2
        call ifill_ch(ib,1,120,' ')
        nch = 1
        nch = ichmv(ib,nch,4Hhead,1,4)
        nch = nch + ib2as(i,ib,nch,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(fastfw(i),ib,nch,7,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(slowfw(i),ib,nch,5,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(foroff(i),ib,nch,6,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(fastrv(i),ib,nch,7,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(slowrv(i),ib,nch,5,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(revoff(i),ib,nch,6,1)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(pslope(i),ib,nch,8,2)
        nch=mcoma(ib,nch)
        nch = nch + ir2as(rslope(i),ib,nch,8,2)
        call logit3(ib,nch,lsor)
      enddo
      call ifill_ch(ib,1,120,' ')
      nch = 1
      nch = ichmv(ib,nch,8Hantenna,,1,8)
      call fs_get_diaman(diaman)
      nch = nch + ir2as(diaman,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_slew1(slew1)
      nch = nch + ir2as(slew1,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_slew2(slew2)
      nch = nch + ir2as(slew2,ib,nch,5,1)
      nch=mcoma(ib,nch)
      call fs_get_lolim1(lolim1)
      nch = nch + ir2as(lolim1,ib,nch,6,1)
      nch=mcoma(ib,nch)
      call fs_get_uplim1(uplim1)
      nch = nch + ir2as(uplim1,ib,nch,6,1)
      nch=mcoma(ib,nch)
      call fs_get_lolim2(lolim2)
      nch = nch + ir2as(lolim2,ib,nch,6,1)
      nch=mcoma(ib,nch)
      call fs_get_uplim2(uplim2)
      nch = nch + ir2as(uplim2,ib,nch,6,1)
      nch=mcoma(ib,nch)
      nch = ichmv(ib,nch,iaxis,1,4) - 1
      call logit3(ib,nch,lsor)

      call ifill_ch(ib,1,120,' ')
      nch = 1
      nch = ichmv(ib,nch,6Hequip,,1,6)
      call fs_get_iacttp(iacttp)
      nch = nch + ib2as(iacttp,ib,nch,3)
      nch=mcoma(ib,nch)
      call fs_get_imaxtpsd(imaxtpsd)
      if (imaxtpsd.eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (imaxtpsd.eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else
        nch = nch + ib2as(itsp(imaxtpsd+1),ib,nch,3)
      endif
      nch=mcoma(ib,nch)
      call fs_get_iskdtpsd(iskdtpsd)
      if (iskdtpsd.eq.-2) then
        nch = nch + ib2as(360,ib,nch,3)
      else if (iskdtpsd.eq.-1) then
        nch = nch + ib2as(330,ib,nch,3)
      else
        nch = nch + ib2as(itsp(iskdtpsd+1),ib,nch,3)
      endif
      nch=mcoma(ib,nch)
      call fs_get_i70kch(i70kch)
      nch = nch + ib2as(i70kch,ib,nch,2)
      nch=mcoma(ib,nch)
      call fs_get_i20kch(i20kch)
      nch = nch + ib2as(i20kch,ib,nch,2)
      nch=mcoma(ib,nch)
      call fs_get_refreq(refreq)
      nch = nch + ir2as(refreq,ib,nch,6,1)
      call logit3(ib,nch,lsor)
      return
      end
