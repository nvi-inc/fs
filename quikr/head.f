      subroutine head(ip)
C  tape head control    <881129.1418>
C 
C  HEAD controls the position of the tape recorder head blocks
C 
C  INPUT VARIABLES: 
C 
      dimension ip(1),pnow(2),poff(2) 
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
C  CONTENTS:  ITAPOF(100)     TAPE HEAD OFFSETS FOR EACH PASS, IN MICRONS
C             POSNHD(2)       CURRENT HEAD POSITION  (OUTPUT)
C             IPASHD(2)       CURRENT PASS NUMBER  (OUTPUT)
C 
C  CALLED SUBROUTINES: POSIT, HDPOS
C 
C  LOCAL VARIABLES: 
      dimension iparm(2),ireg(2)
      integer*2 ibuf(40),ibuf2(40) 
      integer get_buf,ichcm_ch
      logical kread,new
      character cjchar
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C  INITIALIZED VARIABLES: 
      data ilen /40/,ipitch/55/,icntr/385/
C 
C  HISTORY: 
C 
C  DATE  WHO  WHAT
C 841226 MWH  CREATED 
C 850714 WEH  MOVE CAL TO ANOTHER COMMAND, OTHER MINOR THINGS 
C 880228 LAR  ADD HEAD OFFSET TO TAPE AUXILIARY FIELD
C 
C  1. Get class buffer and decide whether we have to move the heads,
C      or just monitor their position.
C 
      pitch=ipitch
      cntr=icntr
      ipass=0 
      ichold = -99
      ioclas = 0
      iclass = 0
      nrec = 0
      iclcm = ip(1) 
      ip(2) = 0
      if (iclcm.eq.0) then                     ! zero class number
        ip(3) = -1 
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      kread=.false. 
      if (ieq.eq.0) then
        goto 500
      else if (cjchar(ibuf,ieq+1).eq.'?') then
        goto 600
      else if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) then
        ibuf(1) = 7
        goto 700
      else if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) then
        ibuf(1) = 6
        goto 700
      endif
C 
C  2. Step through buffer, getting each parameter and decoding it.
C 
      ich = ieq+1
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if(ichcm_ch(parm,1,'b').eq.0) then
        ihd = 3
      else if(ichcm_ch(parm,1,'r').eq.0) then
        ihd = 2
      else if(ichcm_ch(parm,1,'w').eq.0) then
        ihd = 1
      else if (cjchar(parm,1).eq.',') then
        ihd = 3
      else
        ip(3) = -201 
        goto 990
      endif
C 
C  2.2 Get requested head position index. 
C 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.',') then
        ipass = 1
      else
        nc = iflch(parm,4)
        ipass = ias2b(parm,1,nc)
        if (ipass.le.0.or.ipass.gt.100) then
          ip(3) = -202
          goto 990
        endif
      endif
      if (itapof(ipass).lt.-4000) then
        ip(3) = -204
        goto 990
      endif
C 
C  3. Now handle head positioning, one head at a time.
C 
      call fs_get_icheck(icheck(20),20)
      ichold = icheck(20) 
      icheck(20) = 0
      call fs_set_icheck(icheck(20),20)
      ihead = ihd
      call fs_get_ipashd(ipashd)
      do j=1,2
        do i=1,2
          if (ihead.eq.3 .or. ihead.eq.i) then
            call hdpos(i,ipass,ip)
            if(ip(3).lt.0) go to 990
            posnhd(i)=itapof(ipass)
            ipashd(i)=ipass
          endif
        enddo
      enddo
      call fs_set_ipashd(ipashd)
C
C  4. Put Pass Number into AUX data Field, IF WE SET UP THE WRITE HEAD
C                    ^ and a priori tape head offset
C
      if(ihead.eq.2) go to 500
      idumm1 = ib2as(iabs(itapof(ipass)),lauxfm,9,o'40000'+o'400'*4+4)
      idumm1 = ib2as(ipass,lauxfm,5,o'40000'+o'400'*3+3)
      if(itapof(ipass).gt.-0.001) then
        idumm1=ichmv(lauxfm,8,2hff,1,1)
      else
        idumm1=ichmv(lauxfm,8,2hdd,1,1)
      endif
C
      ibuf2(1) = 0
      call char2hol('fm',ibuf2(2),1,2)
      idumm1 = ichmv(ibuf2,5,lauxfm,1,8)
      nch = 12
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
C                   Send out the first 8 chars ...
      ibuf2(1) = 5
      call char2hol('! ',ibuf2(2),1,2)
      nch = 3 
      call put_buf(iclass,ibuf2,-nch,2hfs,0)  
C                   ... as ! type data
      ibuf2(1) = 0  
      call char2hol('fm',ibuf2(2),1,2)
      idumm1 = ichmv(ibuf2,5,lauxfm,9,4)  
      idumm1 = ichmv(ibuf2,9,4h0000,1,4)  
      nch = 12
      call put_buf(iclass,ibuf2,-nch,2hfs,0)  
C                   Send out the last 4 chars and zeros ... 
      ibuf2(1) = 5  
      call char2hol('% ',ibuf2(2),1,2)
      nch = 3 
      call put_buf(iclass,ibuf2,-nch,2hfs,0)  
C 
      call run_matcn(iclass,4)
      call rmpar(ip)
      call clrcl(ip(1))
      iclass = 0
      if(ip(3).lt.0) return
C
C  5. Here we read the device to get current head positions.
C
500   continue
      new = .true.
      call fs_get_ipashd(ipashd)
      do i=1,2
        call posit(i,ipashd(i),pnow(i),ip,new)
        if (ip(3).lt.0) go to 990
        poff(i) = pnow(i) - posnhd(i)
      enddo
C
C  Turn off LVDT Osillator
C
      call lvdof(ip)
      if(ip(3).lt.0) go to 990
      kread=.true.
C
C  6. Now we must prepare a response.
C
600   continue
      if (ichold.ne.-99) then
        icheck(20) = ichold
        call fs_set_icheck(icheck(20),20)
      endif
      if (ichold.ge.0) then
        icheck(20) = 1
        call fs_set_icheck(icheck(20),20)
      endif
      nch = ieq
      if (nch.eq.0) nch = nchar+1
      nch = ichmv(ibuf,nch,2h/ ,1,1)
      call fs_get_ipashd(ipashd)
      do i=1,2
        nch = nch+ib2as(ipashd(i),ibuf,nch,o'100000'+2)
        nch = mcoma(ibuf,nch)
      enddo
C
      if(kread) then
        do i=1,2
          nch = nch+ir2as(posnhd(i),ibuf,nch,8,1)
          nch = mcoma(ibuf,nch)
        enddo
        do i=1,2
          nch = nch+ir2as(poff(i),ibuf,nch,8,1)
          nch = mcoma(ibuf,nch)
        enddo
      endif
C
      nch = nch-2
      call put_buf(ioclas,ibuf,-nch,2hfs,0)
      nrec=1
      ip(3) = 0
      goto 990
C
C  7. Reset alarm or Test/Reset
C
700   continue
      call char2hol('hd',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,2hfs,0)
      nrec = 1
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      if (ip(3).ne.0) return
C
C  9. That's all for now.
C
990   ip(1) = ioclas
      ip(2) = nrec
      call char2hol('q>',ip(4),1,2)
      return
      end 
