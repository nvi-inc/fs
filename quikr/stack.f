      subroutine stack(ip)
C  tape head control by micron position
C
C  STACK controls the position of the tape recorder head blocks
C
C  INPUT VARIABLES:
C
      dimension ip(1),ip2(5)
C        IP(1) - class # of input parameter buffer
C
C  OUTPUT VARIABLES:
C
C        IP(1) - class #
C        IP(2) - # of records
C        IP(3) - error return
C        IP(4) - who we are
C
C  COMMON BLOCKS USED:
      include '../include/fscom.i'
C
C  CONTENTS:  ITAPOF(100)     TAPE HEAD OFFSETS FOR EACH PASS, IN MICRONS
C             POSNHD(2)       CURRENT HEAD POSITION  (OUTPUT)
C             IPASHD(2)       CURRENT PASS NUMBER  (OUTPUT)
C
C  LOCAL VARIABLES:
C
      real*4 pnow(2),poff(2),microns(2)
      logical kmic(2), kauto
      dimension iparm(2),ireg(2),ipas(2)
      integer*2 ibuf(40),ibuf2(40)
      integer get_buf,ichcm_ch
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
      if (cjchar(parm,1).eq.','.and.VLBA.ne.and(drive,VLBA)) then
        kmic(1)=.false.
      else if (cjchar(parm,1).eq.',') then
        ip(3)=-501
        goto 990
      else if(cjchar(parm,1).eq.'*') then
        call fs_get_posnhd(posnhd)
        microns(1)=posnhd(1)
        kmic(1)=.true.
      else
        call gtprm(ibuf,ics,nchar,2,parm,ierr)
        if(ierr.ne.0) then
          ip(3) = -211
          goto 990
        endif
        microns(1)=parm
        kmic(1)=.true.
      endif
C
C  2.2 Get requested micron position
C
      ics=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.',') then
        kmic(2)=.false.
      else if(VLBA.eq.and(drive,VLBA)) then
        ip(3)=-502
        goto 990
      else if(cjchar(parm,1).eq.'*') then
        call fs_get_posnhd(posnhd)
        microns(2)=posnhd(2)
        kmic(2)=.true.
      else
        call gtprm(ibuf,ics,nchar,2,parm,ierr)
        if(ierr.ne.0) then
          ip(3) = -212
          goto 990
        endif
        microns(2)=parm
        kmic(2)=.true.
      endif
C
C  2.3 now get direction
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if(ichcm_ch(parm,1,'u').eq.0) then
        idir=0
      else if(ichcm_ch(parm,1,'f').eq.0) then
        idir=-1
      else if(ichcm_ch(parm,1,'r').eq.0) then
        idir=-2
      else if (cjchar(parm,1).eq.'*') then
        call fs_get_ipashd(ipashd)
        idir=ipashd(1)
      else if (cjchar(parm,1).eq.',') then
        idir=0
      else if(kmic(1)) then
        ip(3) = -213
        goto 990
      endif
      ipas(1)=idir
C
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if(VLBA.eq.and(drive,VLBA).and.cjchar(parm,1).ne.',') then
        ip(3)=-506
        goto 990
      else if(ichcm_ch(parm,1,'u').eq.0) then
        idir=0
      else if(ichcm_ch(parm,1,'f').eq.0) then
        idir=-1
      else if(ichcm_ch(parm,1,'r').eq.0) then
        idir=-2
      else if (cjchar(parm,1).eq.'*') then
        call fs_get_ipashd(ipashd)
        idir=ipashd(2)
      else if (cjchar(parm,1).eq.',') then
        idir=0
      else if(kmic(2)) then
        ip(3) = -214
        goto 990
      endif
      ipas(2)=idir
C
      ihd=0
      if(kmic(1)) ihd=ihd+1
      if(kmic(2)) ihd=ihd+2
      if(ihd.eq.0) then
        ip(3)=-311
        goto 990
      endif
C
C  2.5  Get the offset parameter.
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
        ip(3)=-205
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
      do i=1,2
        if(kmic(i)) then
          posnhd(i)=microns(i)
          ipashd(i)=ipas(i)
          kposhd_fs(i)=.true.
          if(i.eq.1) kautohd_fs=kauto
        endif
      enddo
      call fs_set_ipashd(ipashd)
      call fs_set_posnhd(posnhd)
C
      call lvdonn('lock',ip)
      if(ip(3).ne.0) goto 800
C
      call set_mic(ihd,ipas ,kauto,microns,ip,0.40)
      if(ip(3).ne.0) go to 800
C
C  4. Put micron pos. into AUX data Field, IF WE SET UP THE WRITE HEAD
C
      if(ihd.eq.2) go to 500
      nrec=0
      iclass=0
C
      call fs_get_rack(rack)
      if(MK3.eq.and(rack,MK3)) THEN
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
        call frmaux4(lauxfm4,posnhd,ipashd,kautohd_fs)
        ibuf2(1) = 8
        call char2hol('fm /AUX ',ibuf2(2),1,8)
        idumm1 = ichmv(ibuf2,11,lauxfm4,1,8)
        nch=18
        call put_buf(iclass,ibuf2,-nch,'fs','  ')
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
      if(ieq.eq.0) then
        call lvdonn('lock',ip)
        if(ip(3).ne.0) go to 800
      endif
C
C  read the postions
C
      call fs_get_ipashd(ipashd)
      ihd=3
      if(VLBA.eq.and(drive,VLBA)) ihd=1
      call mic_read(ihd,ipashd,kautohd_fs,pnow,ip)
      if(ip(3).ne.0) goto 800
C
C find the deltas
C
      call fs_get_posnhd(posnhd)
      do i=1,2
        if(ihd.eq.3.or.i.eq.ihd) then
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
      call fs_get_posnhd(posnhd)
      do i=1,2
        if(i.eq.1.or.VLBA.ne.and(drive,VLBA)) then
          nch = nch+ir2as(posnhd(i),ibuf,nch,8,1)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      call fs_get_ipashd(ipashd)
      do i=1,2
        if(i.eq.1.or.VLBA.ne.and(drive,VLBA)) then
          if(ipashd(i).eq.0) then
            call char2hol('u,',idum,1,2)
          else if(mod(ipashd(i),2).eq.0) then
            call char2hol('r,',idum,1,2)
          else
            call char2hol('f,',idum,1,2)
          endif
          nch = ichmv(ibuf,nch,idum,1,2)
        else
          nch = mcoma(ibuf,nch)
        endif
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
      do i=1,2
        if(i.eq.1.or.VLBA.ne.and(drive,VLBA)) then
          nch = nch+ir2as(pnow(i),ibuf,nch,8,1)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      do i=1,2
        if(i.eq.1.or.VLBA.ne.and(drive,VLBA)) then
          nch = nch+ir2as(poff(i),ibuf,nch,8,1)
        endif
        nch = mcoma(ibuf,nch)
      enddo
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
      call lvdofn('unlock',ip2)
      if(ip2(3).ne.0) then
        call logit7(0,0,0,0,ip2(3),ip2(4),ip2(5))
        call clrcl(ip(1))
        ip(1)=0
        ip(2)=0
        goto 999
      endif
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
