      subroutine hdata(ip,itask)
C
C  INPUT VARIABLES:
C
      dimension ip(1)
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
C  LOCAL VARIABLES:
C
      real*4 volts(8)
      dimension iparm(2),ireg(2)
      integer*2 ibuf(40),ibuf2(40)
      integer get_buf
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
      ioclas = 0
      iclass = 0
      nrec = 0
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
      call fs_get_drive(drive)
      if (ieq.eq.0) then
        goto 500
      else if (VLBA.eq.and(drive,VLBA)) then
        ip(3)=-282
        goto 990
      else if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) then
        ibuf2(1) = 7
        goto 700
      else if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) then
        ibuf2(1) = 6
        goto 700
      else
        ip(3)=-281
        goto 990
      endif
C
C  5. Here we read the device to get current head positions.
C
500   continue
C
      call fs_get_drive_type(drive_type)
      nchan=8
      do i=1,nchan
        if(drive_type.ne.VLBA2.or.i.eq.5.or.i.eq.6) then
          call get_atod(i,volts(i),ip)
          if(ip(3).ne.0) goto 800
        endif
      enddo
C
C  6. Now we must prepare a response.
C
600   continue
      nch = ieq
      if (nch.eq.0) nch = nchar+1
      nch = ichmv_ch(ibuf,nch,'/')
C
      do i=1,nchan
        if(drive_type.ne.VLBA2.or.i.eq.5.or.i.eq.6) then
          nch = nch+ir2as(volts(i),ibuf,nch,8,3)
        endif
        nch = mcoma(ibuf,nch)
      enddo
C
      nch = nch-2
      nrec=0
      call add_class(ibuf,-nch,ioclas,nrec)
      ip(3) = 0
      goto 990
C
C  7. Reset alarm or Test/Reset
C
700   continue
      call char2hol('hd',ibuf2(2),1,2)
      nch=4
      iclass = 0
      nrec=0
      call add_class(ibuf2,-nch,iclass,nrec)
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      call class_frm(ibuf,nchar,ip)
      return
C
C   turn off LVDT, for an error
C
800   continue
      if(ip(2).ne.0) call clrcl(ip(1))
      ip(2)=0
      call logit7(0,0,0,0,ip(3),ip(4),ip(5))
      call lvdofn('unlock',ip)
C
C  9. That's all for now.
C
990   ip(1) = ioclas
      ip(2) = nrec
      call char2hol('q@',ip(4),1,2)
      return
      end
