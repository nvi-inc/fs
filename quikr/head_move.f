      subroutine head_move(ihead,idir,ispdhd,tmove,ip)
      integer ihead,idir,ispdhd
      integer*4 ip(5)
      real tmove
C
C  HEAD_MOVE: move a head
C
C  INPUT:
C     IHEAD: head to move, 1 or 2
C     IDIR: direction to move, 0=in or 1=out
C     ISPDHD: speed at which to move, 0=slow or 1=fast
C     TMOVE: time to move, seconds
C
C  OUTPUT:
C     TMOVE: seconds the head were actually requested to move
C     IP - Field System Parmeters
C     IP(3) - error return, 0 = no error
C
      include '../include/fscom.i'
C
      integer iw,iclass,nrec
      integer*2 ibuf(6)
      integer*4 jm
C
      tmove=min(tmove,1.0)                 !limit motion to 1 second
      jm=tmove*25000.*(lvbosc_fs/5.0)      !calculate counts
      jm=max(min(65535,jm),0)              !limit counts
      tmove=jm*(5.0/lvbosc_fs)*40e-6       !calculate actual time
c
      call fs_get_drive(drive)
      if(VLBA.eq.drive.or.VLBA4.eq.drive) then
         call fc_head_vmov(ihead,idir,ispdhd,jm,ip)
      else
c
        nrec=0
        iclass=0
C
        ibuf(1)=0
        call char2hol('hd',ibuf(2),1,2)
c
        call iw2ma(ibuf(3),ispdhd,idir,ihead,jm)
        call add_class(ibuf,-12,iclass,nrec)
C
        ibuf(1)=5
        call char2hol('( ',ibuf(2),1,2)
        call add_class(ibuf,-3 ,iclass,nrec)
C
        call run_matcn(iclass,nrec)
        call rmpar(ip)
        if(ip(3).ne.0) return
C
        call clrcl(ip(1))
        ip(2)=0
        iw=(5.0/lvbosc_fs)*jm/250+2
        call susp(1,iw)
      endif
C
      return
      end
