      subroutine get_atod(ichan,volt,ip)

      integer ichan
      integer*4 ip(5)
      real volt
C
C  GET_ATOD: get A/D sample
C
C     INPUT:
C       ICHAN: channel to sample (1-8, see AD2MA for details)
C
C     OUTPUT:
C       VOLT: sampled voltage
C       IP: field system parameter array
C
      include '../include/fscom.i'
C
      integer*2 ibuf(6)
      integer icount,itest,imove,ilvdt,nchar,iclass,nrec
      integer ilen
      data ilen/12/
C
C  check for and handle VLBA REC
C
      call fs_get_drive(drive)
      if(VLBA.eq.drive.or.VLBA4.eq.drive) then
        call fc_get_vatod(ichan,volt,ip)
        return
      endif
C
C onto M3
C
      nrec=0
      iclass=0
C
      ibuf(1)=0
      call char2hol('hd',ibuf(2),1,2)
      ilvdt=1
      call fs_get_klvdt_fs(klvdt_fs)
      if(klvdt_fs) ilvdt=0
      call ad2ma(ibuf(3),ilvdt,0,ichan)
      call add_class(ibuf,-12,iclass,nrec)
C
      ibuf(1) = -2
      call add_class(ibuf,-12,iclass,nrec)
C
C   Now schedule MATCN
C
      call run_matcn(iclass,nrec)
      call rmpar(ip)
      if(ip(3).ne.0) return
C
C  Get and decode voltage response from MATCN
C
      do i=1,ip(2)
        call get_class(ibuf,-ilen,ip,nchar)
      enddo
      call clrcl(ip(1))
      ip(2)=0
      call ma2ad(ibuf,imove,itest,icount)
      if(imove.ne.0) then
        ip(3)=-401
        call char2hol('q@',ip(4),1,2)
      endif
      volt=icount*4.8828125e-3
C
      return
      end
