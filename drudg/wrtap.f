      SUBROUTINE wrtap(lspdir,ispin,ihead,lu,iwr,ktape,irec,
     .kauto)
C
C  WRTAP writes the tape lines for the VLBA pointing schedules.
C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900724 CREATED
c     gag   901025 added ktape logical for NEXT writing
C     nrv   930709 Now "ihead" is the actual head position in microns,
C                  removed the hard-coded array.
C 970321 nrv Re-write for more flexibility.
C 980728 nrv Remove the HEAD command, for dynamic tape allocation.
C 980910 nrv Remove REWIND and just STOP at the end of a pass.
C 980924 nrv Replace the HEAD command for RDV11.
C 981208 nrv Remove it again.
C 011011 nrv Add KAUTO to the call.
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
C
C  INPUT:
        integer*2 lspdir
      integer ispin,ihead,lu,iwr,irec
      logical ktape,kauto
C
C     CALLED BY: vlbat
C
C  LOCAL VARIABLES
      integer nch,ierr
      integer ib2as,ichmv,ichmv_ch ! functions

      call ifill(ibuf,1,ibuf_len,oblank)

      nch = ichmv_ch(ibuf,1,'tape=(')
      nch = nch + ib2as(irec,ibuf,nch,1) ! recorder number
      nch = ichmv_ch(ibuf,nch,',')
      if (ispin.ne.0) then
        if (ispin.eq.330) then
C         nch=ichmv(ibuf,nch,LSPDIR,1,1)
C         nch = ichmv_ch(ibuf,nch,'REWIND) ')
          nch = ichmv_ch(ibuf,nch,'STOP) ')
        else
          nch=ichmv(ibuf,nch,LSPDIR,1,1)
          nch = ichmv_ch(ibuf,nch,'RUN) ')
        endif
      else
        nch = ichmv_ch(ibuf,nch,'STOP) ')
      end if

      nch = ichmv_ch(ibuf,nch,' write=(')
      nch = nch + ib2as(irec,ibuf,nch,1) ! recorder number
      nch = ichmv_ch(ibuf,nch,',')
      if (iwr.eq.0) then
       nch = ichmv_ch(ibuf,nch,'off)')
      else
        nch = ichmv_ch(ibuf,nch,'on) ')
      end if

      if (.not.kauto) then ! head commands
        nch = ichmv_ch(ibuf,nch,' head=(')
        nch = nch + ib2as(irec,ibuf,nch,1) ! recorder number
        nch = ichmv_ch(ibuf,nch,',')
        nch = nch + ib2as(IHEAD,ibuf,nch,4)
        nch = ichmv_ch(ibuf,nch,')')
      endif
C
      if (ktape) nch = ichmv_ch(ibuf,nch,'  !NEXT!')

      CALL writf_asc(LU,IERR,ibuf,(nch+1)/2)

      RETURN
      END
