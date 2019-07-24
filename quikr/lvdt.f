      subroutine lvdt(ip,itask)
C  tape head control by lvdt voltage
C
C  LVDT controls the position of the tape recorder head blocks
C
C  INPUT VARIABLES:
C
      dimension ip(1),ip2(5)
C        IP(1) - class # of input parameter buffer
C        ITASK - 3 for LVDT voltage position/reading
C        ITASK - 4 for voltage reading with LVDT turned off
C
C  OUTPUT VARIABLES:
C
C        IP(1) - class #
C        IP(2) - # of records
C        IP(3) - error return
C        IP(4) - who we are
C
      include '../include/fscom.i'
C
      real*4 microns(2),volts(2),volt(2)
      logical kvolts(2)
      dimension iparm(2),ireg(2),ipas(2)
      integer*2 ibuf(40),ibuf2(40)
      integer get_buf
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
      data ilen /40/
C
C  HISTORY:
C
C  DATE  WHO  WHAT
C 900222 weh  created by cloning from new PASS command
C
C  1. Get class buffer and decide whether we have to move the heads,
C      or just monitor their position.
C
      ichold = -99
      ioclas = 0
      norec = 0
C
      call fs_get_drive(drive)
      iclcm = ip(1)
      ip(3) = 0
      if (iclcm.eq.0) then                     ! zero class number
        ip(3) = -1
        goto 990
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) then
        goto 500
      else if (itask.eq.4) then
        ip(3)=-321
        goto 990
      else if (cjchar(ibuf,ieq+1).eq.'?') then
        goto 600
      else if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) then
        ibuf2(1) = 7
        goto 700
      else if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) then
        ibuf2(1) = 6
        goto 700
      endif
C
C  2. Step through buffer, getting each parameter and decoding it.
C
      ich = ieq+1
      ics=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        kvolts(1)=.false.
      else if(cjchar(parm,1).eq.','.and.
     &        VLBA.eq.iand(drive,VLBA)) then
        ip(3)=-501
        goto 990
      else if(cjchar(parm,1).eq.'*') then
        call fs_get_ipashd(ipashd)
        call mic2vlt(1,ipashd(1),kautohd_fs,posnhd(1),volts(1),ip)
        if(ip(3).ne.0) goto 990
        kvolts(1)=.true.
      else
        call gtprm(ibuf,ics,nchar,2,parm,ierr)
        if(ierr.ne.0) then
          ip(3) = -221
          goto 990
        endif
        volts(1)=parm
        kvolts(1)=.true.
      endif
C
C  2.2 Get requested voltage position
C
      ics=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        kvolts(2)=.false.
      else if(VLBA.eq.iand(drive,VLBA)) then
        ip(3)=-502
        goto 990
      else if(cjchar(parm,1).eq.'*') then
        call fs_get_ipashd(ipashd)
        call mic2vlt(2,ipashd(2),kautohd_fs,posnhd(2),volts(2),ip)
        if(ip(3).ne.0) goto 990
        kvolts(2)=.true.
      else
        call gtprm(ibuf,ics,nchar,2,parm,ierr)
        if(ierr.ne.0) then
          ip(3) = -222
          goto 990
        endif
        volts(2)=parm
        kvolts(2)=.true.
      endif
C
      ihd=0
      if(kvolts(1)) ihd=ihd+1
      if(kvolts(2)) ihd=ihd+2
      if(ihd.eq.0) then
        ip(3)=-322
        goto 990
      endif
C
C  3. Now handle head positioning
C
      call fs_get_icheck(icheck(20),20)
      ichold = icheck(20)
      icheck(20) = 0
      call fs_set_icheck(icheck(20),20)
C
      call lvdonn('lock',ip)
      if(ip(3).ne.0) goto 800
C
C  save the results in common
C
      call fs_get_ipashd(ipashd)
      do i=1,2
        if(kvolts(i)) then
          call vlt2mic(i,0,.false.,volts(i),microns(i),ip)
          posnhd(i)=microns(i)
          ipashd(i)=0
          kposhd_fs(i)=.true.
          if(i.eq.1) kautohd_fs=.false.
        endif
      enddo
      call fs_set_ipashd(ipashd)
C
      call set_vlt(ihd,volts,ip,0.40)
      if(ip(3).ne.0) go to 800
C
C  4. Put micron pos. into AUX data Field, IF WE SET UP THE WRITE HEAD
C
      if(ihd.eq.2) go to 500
      nrec=0
      iclass=0
C
      call fs_get_rack(rack)
      if(MK3.eq.iand(rack,MK3)) THEN
        call frmaux(lauxfm,nint(posnhd(1)),ipashd(1))
        ibuf2(1) = 0
        call char2hol('fm',ibuf2(2),1,2)
        idumm1 = ichmv(ibuf2,5,lauxfm,1,8)
        nch = 12
        call add_class(ibuf2,-nch,iclass,nrec)
C                   Send out the first 8 chars ...
        ibuf2(1) = 5
        call char2hol('! ',ibuf2(2),1,2)
        nch = 3
        call add_class(ibuf2,-nch,iclass,nrec)
C                     ... as ! type data
        ibuf2(1) = 0
        call char2hol('fm',ibuf2(2),1,2)
        idumm1 = ichmv(ibuf2,5,lauxfm,9,4)
        idumm1 = ichmv(ibuf2,9,4h0000,1,4)
        nch = 12
        call add_class(ibuf2,-nch,iclass,nrec)
C                   Send out the last 4 chars and zeros ...
        ibuf2(1) = 5
        call char2hol('% ',ibuf2(2),1,2)
        nch = 3
        call add_class(ibuf2,-nch,iclass,nrec)
C
        call run_matcn(iclass,nrec)
        call rmpar(ip)
      else if(MK4.eq.iand(rack,MK4)) THEN
        call frmaux4(lauxfm4,posnhd,ipashd,kautohd_fs)
        ibuf2(1) = 8
        call char2hol('fm /AUX ',ibuf2(2),1,8)
        idumm1 = ichmv(ibuf2,11,lauxfm4,1,8)
        nch=18
        call put_buf(iclass,ibuf2,-nch,2Hfs,0)
        nrec=1
        call run_matcn(iclass,nrec)
        call rmpar(ip)
      else !vlba
        call frmaux(lauxfm,nint(posnhd(1)),ipashd(1))
        call fc_set_vaux(lauxfm,ip)
      endif
      call clrcl(ip(1))
      ip(2)=0
      if(ip(3).ne.0)  go to 800
C
C  5. Here we read the device to get current head positions.
C
500   continue
C
C turn on LVDT if we didn't earlier
C
      if(ieq.eq.0.and.itask.eq.3) then
        call lvdonn('lock',ip)
      else if(itask.eq.4) then
        call lvdofn('lock',ip)
      endif
      if(ip(3).ne.0) go to 800
C
C  read the postions
C
      ihd=3
      if(VLBA.eq.iand(drive,VLBA)) ihd=1
      call vlt_read(ihd,volts,ip)
      if(ip(3).ne.0) goto 800
C
C  Turn off LVDT Osillator
C
      call lvdofn('unlock',ip)
      if(ip(3).ne.0) go to 990
C
C  6. Now we must prepare a response.
C
600   continue
      nch = ieq
      if (nch.eq.0) nch = nchar+1
      nch = ichmv(ibuf,nch,2h/ ,1,1)
C
      if(itask.eq.3) then
      call fs_get_ipashd(ipashd)
        do i=1,2
          if(i.eq.1.or.VLBA.ne.iand(drive,VLBA)) then
            call mic2vlt(i,ipashd(i),kautohd_fs,posnhd(i),volt(i),ip)
            nch = nch+ir2as(volt(i),ibuf,nch,8,3)
          endif
          nch = mcoma(ibuf,nch)
        enddo
      endif
C
      do i=1,2
        if(i.eq.1.or.VLBA.ne.iand(drive,VLBA)) then
          nch = nch+ir2as(volts(i),ibuf,nch,8,3)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      if(itask.eq.3) then
        do i=1,2
          if(i.eq.1.or.VLBA.ne.iand(drive,VLBA)) then
            nch = nch+ir2as(volts(i)-volt(i),ibuf,nch,8,3)
          endif
          nch = mcoma(ibuf,nch)
        enddo
      endif
C
      nch = nch-2
      call add_class(ibuf,-nch,ioclas,norec)
      ip(3) = 0
      goto 990
C
C  7. Reset alarm or Test/Reset
C
700   continue
      call char2hol('hd',ibuf2(2),1,2)
      iclass = 0
      nrec=0
      call add_class(ibuf2,-4,iclass,nrec)
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call class_frm(ibuf,nchar,ip)
      goto 999
C
C   turn off LVDT, for an error
C
800   continue
      if(itask.eq.3) then
        call lvdofn('unlock',ip2)
        if(ip2(3).ne.0) call logit7(0,0,0,0,ip2(3),ip2(4),ip2(5))
      endif
      goto 999
C
C  9. That's all for now.
C
990   ip(1) = ioclas
      ip(2) = norec
      call char2hol('q@',ip(4),1,2)
999   continue
      if (ichold.ne.-99) then
        icheck(20) = ichold
        call fs_set_icheck(icheck(20),20)
      endif
      if (ichold.ge.0) then
        icheck(20) = mod(ichold,1000)+1
        call fs_set_icheck(icheck(20),20)
      endif
      return
      end
