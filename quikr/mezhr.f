      subroutine mezhr(avpea,avpeb,iserra,iserrb,ip,iauxa,iauxb,itrk,
     &     ifrma,ifrmb,indxtp)
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
C                04-22-99 WEH
C                changed to read a megabyte of data at a time
C
      integer get_buf
      integer*2 ibuf2(10),ibuf(50),laux(12)
      integer*4 ip(5),jperr(2),jsync(2),jfrms(2),jbits(2)
      integer itrk(2),ireg(2),itrk2(2),iaux(2)
      integer equalizer, itrkl(2)
C
      data itper/25/,ilen/100/
C             - time 10s of milliseconds
c               between samples and # of samples to average
c
      iauxa=0
      iauxb=0
      ifrma=0
      ifrmb=0
100   continue
c
c set reproduce tracks
c
      call fs_get_rack(rack)
      call fs_get_drive(drive)
      if (MK3.eq.drive(indxtp).or.MK4.eq.drive(indxtp)) THEN
        nrec=0
        ibuf2(1)=0
        if(indxtp.eq.1) then
           call char2hol('t1',ibuf2(2),1,2)
        else
           call char2hol('t2',ibuf2(2),1,2)
        endif
        call fs_get_itraka(itraka,indxtp)
        call fs_get_itrakb(itrakb,indxtp)
        if(itrk(1).ne.0) then
           itraka(indxtp)=itrk(1)
           if(MK4.eq.drive(indxtp)) itraka(indxtp)=itraka(indxtp)-1
           call fs_set_itraka(itraka,indxtp)
        endif
        if(itrk(2).ne.0) then
           itrakb(indxtp)=itrk(2)
           if(MK4.eq.drive(indxtp)) itrakb(indxtp)=itrakb(indxtp)-1
           call fs_set_itrakb(itrakb,indxtp)
        endif
        iclass=0
        if (MK3.eq.drive(indxtp)) then
          call rp2ma(ibuf2(3),ibypas(indxtp),ieqtap(indxtp),
     $          ibwtap(indxtp),itraka(indxtp),itrakb(indxtp))
        else if (MK4.eq.drive(indxtp)) then
          call rp2ma4(ibuf2(3),ibypas(indxtp),ieq4tap(indxtp),
     $          itraka(indxtp),itrakb(indxtp))
        endif
        call put_buf(iclass,ibuf2,-13,'fs','  ')
        nrec = nrec+1
        call run_matcn(iclass,nrec)
        call rmpar(ip)
      else !VLBA or VLBA4
         itrkl(1)=itrk(1)-1
         itrkl(2)=itrk(2)-1
         call fc_set_vrptrk(itrkl, ip,indxtp)
      endif
      if(ip(3).lt.0) return
      call clrcl(ip(1))
c
c  Initialize error counters for this track
c
      iperra=0
      iperrb=0
      isyna=0
      isynb=0
      iserra=0
      iserrb=0
c
c determines centiseconds for a full megabyte
c
      if(MK4.eq.drive(indxtp)) then
         itper=800/(2**(5-ibr4tap(indxtp)))
      else if (MK3.eq.drive(indxtp)) then
         itper=100*2**(7-ibwtap(indxtp))
      else if(drive(indxtp).eq.VLBA.or.drive(indxtp).eq.VLBA4) then
         call fs_get_vrepro_equalizer(equalizer,1,indxtp)
         call fs_get_drive_type(drive_type)
         if(.not.
     $        (drive(indxtp).eq.VLBA.and.drive_type(indxtp ).eq.VLBA2)
     $        ) then
            if(equalizer.eq.1) then
               itper=200
            else if(equalizer.eq.2) then
               itper=100
            else 
               itper=200
            endif
         else                   !VLBA2
            if(equalizer.eq.0) then
               itper=200
            else if(equalizer.eq.1) then
               itper=100
            else 
               itper=200
            endif
         endif
      endif
c
      if (decoder4.eq.3) then
c
c  initialize decoder error counters
c
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
c sample
c
         do i=1,2
            do ii=1,2 
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
                     if(i.eq.2) then
                        iperra=count-iperra
                        isyna=isync-isyna
                     else if(i.eq.1) then
                        iperra=count
                        isyna=isync
                     endif
                  else
                     if(i.eq.2) then
                        iperrb=count-iperrb
                        isynb=isync-isynb
                     else if(i.eq.1) then
                        iperrb=count
                        isynb=isync
                     endif
                  endif
               endif
            enddo
c
c  wait for a megabyte worth
c
            if(i.eq.1) call susp(1,itper)
         enddo
      else if(decoder4.eq.4) then
        ibuf2(1)=10
        call char2hol('de',ibuf2(2),1,2)
        call char2hol('dqa clear',ibuf2(3),1,10)
        iclass=0
        call put_buf(iclass,ibuf2,-14,'fs','  ')
        call run_matcn(iclass,1) 
        call rmpar(ip)
        if(ip(3).lt.0) return 
        call clrcl(ip(1)) 
c
c  wait for a megabyte worth
c
        call susp(1,itper)
c
c sample
c
        ibuf2(1)=10
        call char2hol('de',ibuf2(2),1,2)
        call char2hol('dqa',ibuf2(3),1,4)
        iclass=0
        call put_buf(iclass,ibuf2,-7,'fs','  ')
        call run_matcn(iclass,1) 
        call rmpar(ip)
        if(ip(3).lt.0) return 
        iclass=ip(1)
        ireg(2) = get_buf(iclass,ibuf,-(ilen-1),idum,idum)
        call pchar(ibuf,ireg(2)+1,0)
        call fc_dqa4_cnvrt(ibuf(2),jfrms,jperr,jsync,ierr)
        if(ierr.ne.0) then
           ip(1)=0
           ip(3)=-313
           call char2hol('qg',ip(4),1,2)
           return
        endif
        if(itrk(1).ne.0) then
           if(jfrms(1).gt.0) then
              iperra=nint(jperr(1)*400.0/jfrms(1))
              isyna=nint(jsync(1)*400.0/jfrms(1))
           else
              iperra=100000
              isynb=400
           endif
           if(jfrms(1).lt.360) then
              ifrma=0
           else
              ifrma=1
           endif
        endif
        if(itrk(2).ne.0) then
           if(jfrms(2).gt.0) then
              iperrb=nint(jperr(2)*400.0/jfrms(2))
              isynb=nint(jsync(2)*400.0/jfrms(2))
           else
              iperrb=100000
              isynb=400
           endif
           if(jfrms(2).lt.360) then
              ifrmb=0
           else
              ifrmb=1
           endif
        endif
C
C DQA module
C 
      else if(decoder4.eq.1) then !vlba rack
         call fc_get_verate(jperr,jsync,jbits,itrk,itper,ip)
         if(ip(3).lt.0) return
         if(itrk(1).ne.0) then
            iperra=jperr(1)
            isyna=jsync(1)
            if(jbits(1).lt.7200000) then
               ifrma=0
            else
               ifrma=1
            endif
         endif
         if(itrk(2).ne.0) then
            iperrb=jperr(2)
            isynb=jsync(2)
            if(jbits(2).lt.7200000) then
               ifrmb=0
            else
               ifrmb=1
            endif
         endif
      else                      !none
        call susp(1,200)
      endif
C 
      if(itrk(1).ne.0) then
        avpea=iperra
        iserra=isyna
      endif
      if(itrk(2).ne.0) then
        avpeb=iperrb
        iserrb=isynb
      endif
C
C  4.  Check AUX data.
C
      if (.not.kdoaux_fs(indxtp)) goto 990
c
c  Check COMMON for AUX data
c
      if (MK3.eq.rack) then
         do i=1,6
            if(lauxfm(i).ne.0) goto 401
         enddo
         goto 990               !no aux to check
      else if(MK4.eq.rack.or.VLBA4.eq.rack) then
         do i=1,4
            if(lauxfm4(i).ne.0) goto 401
         enddo
         goto 990
      endif
      goto 990
c
 401  continue
      if (decoder4.eq.3) then
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
C
C this deletes the extra class record that comes if the decoder is
C not clocking because either the decoder is disconnect (one side or both)
C or the formatter is not connected to the recorder (one side or the other)
C
                  call clrcl(iclass)
                  nch=ichmv(laux,nch,ibuf,3,4)
                  if(i.eq.1) nch=ichmv(laux,nch,ibuf,7,4)
               enddo
               call lower(laux(6*(ii-1)+1),12)
               if (MK3.eq.rack) then
                  if(ichcm(laux,12*(ii-1)+1,lauxfm,1,12).ne.0) then
                     if(ii.eq.1) iauxa = 1
                     if(ii.eq.2) iauxb = 1
                  endif
               else if(MK4.eq.rack.or.VLBA4.eq.rack) then
                  if(ichcm(laux,12*(ii-1)+1,lauxfm4,1,8).ne.0) then
                     if(ii.eq.1) iauxa = 1
                     if(ii.eq.2) iauxb = 1
                  endif
               endif
            endif
         enddo
      else if(decoder4.eq.4) then
        ibuf2(1)=10
        call char2hol('de',ibuf2(2),1,2)
        call char2hol('aux',ibuf2(3),1,4)
        iclass=0
        call put_buf(iclass,ibuf2,-7,'fs','  ')
        call run_matcn(iclass,1) 
        call rmpar(ip)
        if(ip(3).lt.0) return 
        iclass=ip(1)
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        inextc=ichmv(laux,1,ibuf(2),17,4)
        inextc=ichmv(laux,inextc,ibuf(2),22,4)
        inextc=ichmv(laux,inextc,ibuf(2),27,4)
        inextc=ichmv(laux,inextc,ibuf(2),37,4)
        inextc=ichmv(laux,inextc,ibuf(2),42,4)
        inextc=ichmv(laux,inextc,ibuf(2),47,4)
        call lower(laux,24)
        if (MK3.eq.rack) then
           if(ichcm(laux, 1,lauxfm,1,12).ne.0) then
              iauxa = 1
           endif
           if(ichcm(laux,13,lauxfm,1,12).ne.0) then
              iauxb = 1
           endif
        else if(MK4.eq.rack.or.VLBA4.eq.rack) then
           if(ichcm(laux, 1,lauxfm4,1,8).ne.0) then
              iauxa = 1
           endif
           if(ichcm(laux,13,lauxfm4,1,8).ne.0) then
              iauxb = 1
           endif
        endif
      else if(decoder4.eq.1) then  !vlba DQA
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
            if(MK3.eq.drive(indxtp).or.MK4.eq.drive(indxtp)) THEN
               nrec=0
               ibuf2(1)=0
               if(indxtp.eq.1) then
                  call char2hol('t1',ibuf2(2),1,2)
               else
                  call char2hol('t2',ibuf2(2),1,2)
               endif
               itraka(indxtp)=itrk(2)-1
               itrakb(indxtp)=itrk(1)-1
               call fs_set_itraka(itraka,indxtp)
               call fs_set_itrakb(itrakb,indxtp)
               iclass=0
               if (MK3.eq.drive(indxtp)) then
                 call rp2ma(ibuf2(3),ibypas(indxtp),ieqtap(indxtp),
     $                 ibwtap(indxtp),itraka(indxtp),itrakb(indxtp))
               else if (MK4.eq.drive(indxtp)) then
                  call rp2ma4(ibuf2(3),ibypas(indxtp),ieq4tap(indxtp),
     $                 itraka(indxtp), itrakb(indxtp))
                  call put_buf(iclass,ibuf2,-13,'fs','  ')
                  nrec = nrec+1
               endif
               call put_buf(iclass,ibuf2,-13,'fs','  ')
               nrec=nrec+1
               call run_matcn(iclass,nrec)
               call rmpar(ip)
            else                !VLBA drive
               itrk2(1)=itrk(2)
               itrk2(2)=itrk(1)
               call fc_set_vrptrk(itrk2, ip,indxtp)
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

