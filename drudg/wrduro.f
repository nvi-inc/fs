      SUBROUTINE wrdur(kx,ksw,istart,idur,iqual,ih,im,is,
     .  iz2,iz3,lu,isetup)
C
C  WRDUR writes the dur lines for the VLBA
C  pointing schedules.
C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900726 CREATED
C     nrv   910524 Added subscript to kswitch
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
C
C  INPUT:
        logical ksw,kx
      integer ih,im,is,idur,iqual,lu
      integer iz2,iz3
        integer istart,isetup
C
C     CALLED BY: vlbat
C
C  LOCAL VARIABLES
      character*32 cdur
      integer iput,idum,ierr
        integer ib2as ! functions
C
C  INITIALIZED:
      DATA cdur/'dur=00s qual=    stop=00h00m00s '/
C
C
C  Set dur=0 so that stop time is used
C  The stop time for the setup block is the start time of the scan

      iput = 16
      if ((ksw).and.(isetup.eq.0)) then
        call char2hol('!BEGIN LOOP! ',ibuf,1,13)
        iput = 22
      else if ((.not.ksw).and.(isetup.eq.0)) then
        call char2hol(' !NEXT!',ibuf,33,40)
        iput = 20
      endif
      call char2hol(cdur,ibuf,istart,istart+31)
      idum = ib2as(idur,ibuf,istart+4,iz2)
      if (idur.eq.0) then
        call char2hol('  ',ibuf,istart+5,istart+6)
      else
        call char2hol('s',ibuf,istart+6,istart+6)
      end if
      Idum = ib2as(iqual,ibuf,istart+13,iz3)
      Idum = ib2as(ih,ibuf,istart+22,iz2)
      Idum = ib2as(im,ibuf,istart+25,iz2)
      Idum = ib2as(is,ibuf,istart+28,iz2)
      if (.not.kx) iput=8
      CALL writf_asc(LU,IERR,ibuf,iput)

      RETURN
      END

