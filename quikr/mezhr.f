      subroutine mezhr(avpea,avpeb,iserra,iserrb,ip,iauxa,iauxb,itrk)
C
      include '../include/fscom.i'
C
C MEZHR measures parity and sync errors for two tracks sent as arguments
C
C LAST MODIFIED: 04-24-86 W.E. Himwich
C                made form of AUX parameter agree with parity
C                and synch, i.e. one variable for A and one for B
C                instead of array
C                12-10-85 J.C. Webber
C                Changed to 5 instead of 4 readings, spaced at 0.33 sec
C                instead of 0.50 sec.  Changed criterion from average
C                of best two to best value of all readings.  Output
C                remains in original format (subroutine argument).
C
      integer get_buf
      real perra(5),perrb(5)
      integer*2 ibuf2(10),ibuf(20),laux(12)
      integer*4 ip(5),jperr(2),jsync(2)
      integer itrk(2),isyna(5),isynb(5),ireg(2),itrk2(2),iaux(2)
      integer equalizer
C
      data itper/25/,nav/4/,ilen/40/
C             - time 10s of milliseconds
c               between samples and # of samples to average
c
      iauxa=0
      iauxb=0
      avpea=-1.
      avpeb=-1.
      iserra=-1
      iserrb=-1
100   continue
c
c set reproduce tracks
c
      call fs_get_rack(rack)
      call fs_get_drive(drive)
      if ((MK3.eq.and(drive,MK3)).or.(MK4.eq.and(drive,MK4))) THEN
        nrec=0
        ibuf2(1)=0
        call char2hol('tp',ibuf2(2),1,2)
        call fs_get_itraka(itraka)
        call fs_get_itrakb(itrakb)
        if(itrk(1).ne.0) itraka=itrk(1)
        if(itrk(2).ne.0) itrakb=itrk(2)
        call fs_set_itraka(itraka)
        call fs_set_itrakb(itrakb)
        iclass=0
        if (MK3.eq.and(MK3,drive)) then
          call rp2ma(ibuf2(3),ibypas,ieqtap,ibwtap,itraka,itrakb)
        else if (MK4.eq.and(MK4,drive)) then
          call rp2ma4(ibuf2(3),ibypas,ieq4tap,itraka,itrakb)
          call put_buf(iclass,ibuf2,-13,'fs','  ')
          nrec = nrec+1
          call rpbr2ma4(ibuf2(3),ibr4tap)  !! bitrate has a different strobe
        endif
        call put_buf(iclass,ibuf2,-13,'fs','  ')
        nrec = nrec+1
        call run_matcn(iclass,nrec)
        call rmpar(ip)
      else !VLBA
        call fc_set_vrptrk(itrk, ip)
      endif
      if(ip(3).lt.0) return
      call clrcl(ip(1))
c
c  Initialize error counters for this track
c
      perra(1)=0.
      perrb(1)=0.
      isyna(1)=0
      isynb(1)=0
      iserra=0
      iserrb=0
c
c  initialize decoder error counters
c
      if ((MK3.eq.and(rack,MK3)).or.(MK4.eq.and(rack,MK4))) then
        ibuf2(1)=0
        call char2hol('de%',ibuf2(2),1,3)
        iclass=0
        call put_buf(iclass,ibuf2,-5,'fs','  ')
        call run_matcn(iclass,1) 
        call rmpar(ip)
        if(ip(3).lt.0) return 
        call clrcl(ip(1)) 
        call char2hol('00000008',ibuf2,5,12)
c
c  sample nav+1 times
c
        do i=1,nav+1
c 
c    Now read the errors for tracks A & B 
c
          do  ii=1,2 
            if(itrk(ii).ne.0) then
              if(ii.eq.1) then
                call char2hol('0',ibuf2,11,11) 
              else
                call char2hol('1',ibuf2,11,11) 
              endif
              ibuf2(1)=0
              call char2hol('de00',ibuf2(2),1,4)
              iclass=0
              call put_buf(iclass,ibuf2,-12,'fs','  ') 
              ibuf2(1)=8
              call char2hol('de> ',ibuf2(2),1,4)
              call put_buf(iclass,ibuf2,-5,'fs','  ')
              call char2hol('/ ',ibuf2(3),1,2)
              call put_buf(iclass,ibuf2,-5,'fs','  ')
              call run_matcn(iclass,3) 
              call rmpar(ip)
              if(ip(3).lt.0) return 
              iclass=ip(1)
              ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
              ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
              ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
              count=0.
              do j=1,6
                ia=ia2hx(ibuf,j+4)
                count=count+ia*16.**(6-j) 
              enddo
              isync=ia2hx(ibuf,3)*16+ia2hx(ibuf,4)
              if(ii.eq.1) then
                perra(i)=count
                isyna(i)=isync
              else
                perrb(i)=count
                isynb(i)=isync
              endif
            endif
          enddo
          if(i.le.nav) call susp(1,itper) !don't wait after last sample
        enddo
C 
C  2.  Find average error rates for tracks A and B
C 
C  Get #'s of parity errors (difference between successive readings)
C 
        do i=1,nav
          if(itrk(1).ne.0) then
            perra(i)=perra(i+1)-perra(i)
            isyna(i)=isyna(i+1)-isyna(i)
          endif
          if(itrk(2).ne.0) then
            perrb(i)=perrb(i+1)-perrb(i)
            isynb(i)=isynb(i+1)-isynb(i)
          endif
        enddo
      else !vlba rack
        do i=1,nav
          call fc_get_verate(jperr,jsync,itrk,itper,ip)
          if(ip(3).lt.0) return
          if(itrk(1).ne.0) then
            perra(i)=jperr(1)
            isyna(i)=jsync(1)
          endif
          if(itrk(2).ne.0) then
            perrb(i)=jperr(2)
            isynb(i)=jsync(2)
          endif
        enddo
      endif
C 
C  Sum each error type and identify largest value for each
C 
C --JCW--
C
C Use the smallest value of parity error found
C
      if(itrk(1).ne.0) then
        suma=perra(1)
        isysma=isyna(1)
      endif
      if(itrk(2).ne.0) then
        sumb=perrb(1)
        isysmb=isynb(1)
      endif
      do i=2,nav
        if(itrk(1).ne.0) then
          suma=min(suma,perra(i))
          isysma=min(isysma,isyna(i))
        endif
        if(itrk(2).ne.0) then
          sumb=min(sumb,perrb(i))
          isysmb=min(isysmb,isynb(i))
        endif
      enddo
      if (MK3.eq.and(drive,MK3)) then
        secs=2**(7-ibwtap)      ! seconds for a full megabyte
      else if (MK4.eq.and(drive,MK4)) then
        secs=1     !!! MAKE ONE UNTIL MORE KNOWLEDGE OF MK4 !!! 
      else
        call fs_get_vrepro_equalizer(equalizer,1)
        if(equalizer.eq.1) then
          secs=2.0
        else if(equalizer.eq.2) then
          secs=1.0
        else 
          secs=1.0
        endif
      endif
      tper=(itper*0.01)-0.005 ! average sample period 
      if(itrk(1).ne.0) then
        avpea=nint(suma*(secs/tper))
        iserra=nint(float(isysma)*(secs/tper))
      endif
      if(itrk(2).ne.0) then
        avpeb=nint(sumb*(secs/tper))
        iserrb=nint(float(isysmb)*(secs/tper))
      endif
C
C  4.  Check AUX data.
C
      if (.not.kdoaux_fs) goto 990
      if ((MK3.eq.and(rack,MK3)).or.(MK4.eq.and(rack,MK4))) then
c
c  Check COMMON for AUX data
c
        if (MK3.eq.and(rack,MK3)) then
          do i=1,6
            if(lauxfm(i).ne.0) goto 401
          enddo
          goto 990     !no aux to check
        else if (MK4.eq.and(rack,MK4)) then
          do i=1,4
            if(lauxfm4(i).ne.0) goto 401
          enddo
        endif
c
401     continue
        do ii=1,2
          if(itrk(ii).ne.0)then
            nch=1+12*(ii-1)
            do i=1,2
              idumm1 = ichmv_ch(ibuf2,5,'00000000')
              if(ii.eq.2) idumm1 = ichmv_ch(ibuf2,11,'1')
              if(i.eq.1) idumm1 = ichmv_ch(ibuf2,12,'0')
              if(i.eq.2) idumm1 = ichmv_ch(ibuf2,12,'1')
              ibuf2(1)=0
              call char2hol('de',ibuf2(2),1,2)
              iclass=0
              call put_buf(iclass,ibuf2,-12,'fs','  ')
              ibuf2(1)=5
              call char2hol('> ',ibuf2(2),1,2)
              call put_buf(iclass,ibuf2,-3,'fs','  ')
              call char2hol('/ ',ibuf2(2),1,2)
              call put_buf(iclass,ibuf2,-3,'fs','  ')
              call run_matcn(iclass,3)
              call rmpar(ip)
              iclass=ip(1)
              if(ip(3).lt.0) return
              do j=1,3
                ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
              enddo
              nch=ichmv(laux,nch,ibuf,3,4)
              if(i.eq.1) nch=ichmv(laux,nch,ibuf,7,4)
            enddo
            call lower(laux(6*(ii-1)+1),12)
            if (MK3.eq.and(MK3,rack)) then
              if(ichcm(laux,12*(ii-1)+1,lauxfm,1,12).ne.0) then
                if(ii.eq.1) iauxa = 1
                if(ii.eq.2) iauxb = 1
              endif
            else if (MK4.eq.and(MK4,rack)) then
              if(ichcm(laux,12*(ii-1)+1,lauxfm4,1,12).ne.0) then
                if(ii.eq.1) iauxa = 1
                if(ii.eq.2) iauxb = 1
              endif
            endif
          endif
        enddo

      else !vlba RACK
        call fc_get_vaux(iaux,itrk,ip) !check our aux data
        if(ip(3).lt.0) return
        call clrcl(ip(1))
        do i=1,2
          if(iaux(i).eq.1) then
            if(i.eq.1)  then
              iauxa=1
            else
              iauxb=1
            endif
          endif
        enddo
        if(itrk(1).ne.0.and.itrk(2).ne.0) then !swap a & b tracks
C !mk3 or mk4 drive (&VLBA rack), not likely
          if((MK3.eq.and(drive,MK3)).or.(MK4.eq.and(drive,MK4))) THEN
            nrec=0
            ibuf2(1)=0
            call char2hol('tp',ibuf2(2),1,2)
            itraka=itrk(2)
            itrakb=itrk(1)
            call fs_set_itraka(itraka)
            call fs_set_itrakb(itrakb)
            iclass=0
            if (MK3.eq.and(drive,MK3)) then
              call rp2ma(ibuf2(3),ibypas,ieqtap,ibwtap,itraka,itrakb)
            else if (MK4.eq.and(drive,MK4)) then
              call rp2ma4(ibuf2(3),ibypas,ieq4tap,itraka,itrakb)
              call put_buf(iclass,ibuf2,-13,'fs','  ')
              nrec = nrec+1
              call rpbr2ma4(ibuf2(3),ibr4tap)  !! bitrate has a different strobe
            endif
            call put_buf(iclass,ibuf2,-13,'fs','  ')
            nrec=nrec+1
            call run_matcn(iclass,nrec)
            call rmpar(ip)
          else !VLBA drive
            itrk2(1)=itrk(2)
            itrk2(2)=itrk(1)
            call fc_set_vrptrk(itrk2, ip)
          endif
          if(ip(3).lt.0) return
          call clrcl(ip(1))
          call fc_get_vaux(iaux,itrk2,ip)
          if(ip(3).lt.0) return
          call clrcl(ip(1))
          do i=1,2
            if(iaux(i).eq.1) then
              if(i.eq.1)  then
                iauxa=1
              else
                iauxb=1
              endif
            endif
          enddo
        endif
      endif
c
990   return
      end
