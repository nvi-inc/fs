      subroutine pass(ip)
C
C  PASS controls the position of the tape recorder head blocks
C
C  INPUT VARIABLES:
C
      dimension ip(1),ip2(1)
C        IP(1) - class # of input parameter buffer
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
      real*4 pnow(2),poff(2),microns(2)
      logical kpas(2),kauto
      character cjchar
      dimension iparm(2),ireg(2),ipas(2)
      integer*2 ibuf(40),ibuf2(40)
      integer get_buf,ichcm_ch
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
      data ilen /40/
C
C  HISTORY:
C
C  DATE  WHO  WHAT
C 841226 MWH  CREATED
C 850714 WEH  MOVE CAL TO ANOTHER COMMAND, OTHER MINOR THINGS
C 880228 LAR  ADD HEAD OFFSET TO TAPE AUXILIARY FIELD
C 900222 weh  completely rewritten
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
C  2.1 Get first requested head position index.
C
      ich = ieq+1
      ichs = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        kpas(1)=.false.
      else if(cjchar(parm,1).eq.'*') then
        call fs_get_ipashd(ipashd)
        ipas(1)=ipashd(1)
        kpas(1)=.true.
      else if(ichcm_ch(ibuf,ichs,'stack2').eq.0.and.
     .        (MK4.eq.and(drive,MK4))) then
        call fs_get_ipashd(ipashd)
        ipas(1)=ipashd(2)
        kpas(1)=.true.
      else
        nc = iflch(parm,4)
        ipas(1) = ias2b(parm,1,nc)
        kpas(1)=.true.
        if (ipas(1).le.0.or.ipas(1).gt.100) then
          ip(3) = -201
          goto 990
        endif
      endif
      if (kpas(1)) then
       if (itapof(ipas(1)).lt.-4000) then
         ip(3) = -301
         goto 990
       endif
      endif
C
C  2.2 Get second requested head position index.
C
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
      ichs=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.','.or.MK3B.eq.drive_type) then
        kpas(2)=.false.
      else if(VLBA.eq.drive) then
        ip(3)=-501
        goto 990
      else if(ichcm_ch(ibuf,ichs,'same').eq.0.and.kpas(1)) then
        kpas(2)=.true.
        ipas(2)=ipas(1)
      else if(ichcm_ch(ibuf,ichs,'$').eq.0.and.kpas(1)) then
        kpas(2)=.true.
        ipas(2)=ipas(1)
      else if(ichcm_ch(ibuf,ichs,'mk4').eq.0.and.kpas(1)) then
        kpas(2)=.true.
        ipas(2)=ipas(1)+100
      else if(ichcm_ch(ibuf,ichs,'stack1').eq.0.and..not.kpas(1)) then
        kpas(2)=.true.
        ipas(2)=ipashd(1)
      else if(cjchar(parm,1).eq.'*') then
        call fs_get_ipashd(ipashd)
        ipas(2)=ipashd(2)
        kpas(2)=.true.
      else
        nc = iflch(parm,4)
        ipas(2) = ias2b(parm,1,nc)
        kpas(2)=.true.
        if (ipas(2).le.0.or.ipas(2).gt.200) then
          ip(3) = -202
          goto 990
        endif
      endif
      if(kpas(2)) then
        if (itapof(ipas(2)).lt.-4000) then
          ip(3) = -302
          goto 990
        endif
      endif
C
      ihd=0
      if(kpas(1)) ihd=ihd+1
      if(kpas(2)) ihd=ihd+2
      if(ihd.eq.0) then
        ip(3)=-303
        goto 990
      endif
C
C  2.3  Get the offset parameter.
C
      ichs=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        kauto=.true.
      else if (cjchar(parm,1).eq.'*') then
        kauto=kautohd_fs
      else if (ichcm_ch(ibuf,ichs,'none').eq.0) then
        kauto=.false.
      else if (ichcm_ch(ibuf,ichs,'auto').eq.0) then
        kauto=.true.
      else
        ip(3)=-203
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
C  save the results in common
C
      call fs_get_ipashd(ipashd)
      call fs_get_posnhd(posnhd)
C
      do i=1,2
        if(kpas(i)) then
          call pas2mic(i,ipas(i),microns(i),ip)
          posnhd(i)=microns(i)
          ipashd(i)=ipas(i)
          kposhd_fs(i)=.true.
          if(i.eq.1) kautohd_fs=kauto
        endif
      enddo
C
      call fs_set_ipashd(ipashd)
      call fs_set_posnhd(posnhd)
C
      call lvdonn('lock',ip)
      if(ip(3).ne.0) goto 800
C
      call set_pass(ihd,ipas ,kauto,microns,ip,0.40)
      if(ip(3).ne.0) go to 800
C
C
C  4. Put micron pos. into AUX data Field, IF WE SET UP THE WRITE HEAD
C
      nrec=0
      iclass=0
C
      call fs_get_rack(rack)
      if(MK3.eq.and(rack,MK3)) THEN
        if(ihd.eq.2) go to 500
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
C                   ... as ! type data
        ibuf2(1) = 0
        call char2hol('fm',ibuf2(2),1,2)
        idumm1 = ichmv(ibuf2,5,lauxfm,9,4)
        idumm1 = ichmv_ch(ibuf2,9,'0000')
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
      else if(MK4.eq.and(rack,MK4)) THEN
        call frmaux4(lauxfm4,posnhd)
        ibuf2(1) = 9
        call char2hol('fm/AUX 0x',ibuf2(2),1,9)
        idumm1 = ichmv(ibuf2,12,lauxfm4,1,4)
        call char2hol(' 0x',ibuf2,16,18)
        idumm1 = ichmv(ibuf2,19,lauxfm4,5,4)
        nch=22
        call put_buf(iclass,ibuf2,-nch,'fs','  ')
        nrec=1
        call run_matcn(iclass,nrec)
        call rmpar(ip)
      else !vlba
        if(ihd.eq.2) go to 500
        call frmaux(lauxfm,nint(posnhd(1)),ipashd(1))
        call fc_set_vaux(lauxfm,ip)
      endif
      call clrcl(ip(1))
      ip(2)=0
      if(ip(3).lt.0)  go to 800
C
C  5. Here we read the device to get current head positions.
C
500   continue
C
C turn on LVDT if we didn't earlier
C
      if(ieq.eq.0) then
        call lvdonn('lock',ip)
        if(ip(3).ne.0) go to 800
      endif
C
C  read the postions
C
      call fs_get_ipashd(ipashd)
      ihd=3
      if(VLBA.eq.drive.or.MK3B.eq.drive_type) ihd=1
      call mic_read(ihd,ipashd,kautohd_fs,pnow,ip)
      if(ip(3).ne.0) goto 800
C
C find the deltas
C
      call fs_get_posnhd(posnhd)
      do i=1,2
        if(ihd.eq.3.or.ihd.eq.1) then
          poff(i) = pnow(i) - posnhd(i)
        endif
      enddo
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
      nch = ichmv_ch(ibuf,nch,'/')
      call fs_get_ipashd(ipashd)
      do i=1,2
        if(i.eq.1.or.(VLBA.ne.drive.and.drive_type.ne.MK3B)) then
          nch = nch+ib2as(ipashd(i),ibuf,nch,o'100000'+3)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      if (kautohd_fs) then
        call char2hol('auto',ibuf,nch,nch+3)
      else
        call char2hol('none',ibuf,nch,nch+3)
      endif
      nch = nch + 4
      nch = mcoma(ibuf,nch)
C
      call fs_get_posnhd(posnhd)
      do i=1,2
        if(i.eq.1.or.(VLBA.ne.drive.and.drive_type.ne.MK3B)) then
          nch = nch+ir2as(posnhd(i),ibuf,nch,8,1)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      do i=1,2
        if(i.eq.1.or.(VLBA.ne.drive.and.drive_type.ne.MK3B)) then
          nch = nch+ir2as(pnow(i),ibuf,nch,8,1)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      do i=1,2
        if(i.eq.1.or.(VLBA.ne.drive.and.drive_type.ne.MK3B)) then
          nch = nch+ir2as(poff(i),ibuf,nch,8,1)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      nch = nch-2
      call add_class(ibuf ,-nch,ioclas,norec)
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
      call lvdofn('unlock',ip2)
      if(ip2(3).ne.0) then
        call logit7(0,0,0,0,ip2(3),ip2(4),ip2(5))
        call clrcl(ip(1))
        ip(1)=0
        ip(2)=0
        goto 999
      endif
C

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
