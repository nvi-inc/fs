      subroutine read_snap1(cbuf,cexper,iyear,cstn,cid1,cid2,ierr)

C Read the first comment line of a SNAP file in free-field format.
C Format:
C" VT2       1996 SHANG     S  
C           read(cbuf,9001) cexper,iyear,cstn,cid !header line
C9001        format(2x,a8,2x,i4,1x,a8,2x,a2)

C 970312 nrv Created to remove formatted reads.

C Called by: LSTSUM, CLIST, LABEL

C Input
      character*(*) cbuf
C Output
      character*8 cexper,cstn
      integer iyear
      character*2 cid2
      character*1 cid1
      integer ierr

C Local
      integer ic1,ic2,ich,ilen
      integer*2 ibuf(40)

C 1. Convert to hollerith, find length, get the fields.

      ierr=0
      call char2hol(cbuf,ibuf,1,80)
      ilen = iflch(ibuf,80)
      ich=2 ! start after the "
      call gtfld(ibuf,ich,ilen,ic1,ic2) ! experiment name
      ierr=-1
      if (ic1.eq.0) return
      nch = ic2-ic1+1
      if (nch.le.0) return
      if (nch.gt.8) nch=8
      call hol2char(ibuf,ic1,ic2,cexper)
      call gtfld(ibuf,ich,ilen,ic1,ic2) ! year
      ierr=-2
      if (ic1.eq.0) return
      nch = ic2-ic1+1
      if (nch.le.0) return
      iyear = ias2b(ibuf,ic1,nch)
      call gtfld(ibuf,ich,ilen,ic1,ic2) ! station name
      ierr=-3
      if (ic1.eq.0) return
      nch = ic2-ic1+1
      if (nch.le.0) return
      if (nch.gt.8) nch=8
      call hol2char(ibuf,ic1,ic2,cstn)
      call gtfld(ibuf,ich,ilen,ic1,ic2) ! 1-letter ID
      ierr=-4
      if (ic1.eq.0) return
      nch = ic2-ic1+1
      if (nch.le.0) return
      if (nch.gt.1) nch=1
      call hol2char(ibuf,ic1,ic2,cid1)
      call gtfld(ibuf,ich,ilen,ic1,ic2) ! 2-letter ID
      ierr=-5
      if (ic1.eq.0) return
      nch = ic2-ic1+1
      if (nch.le.0) return
      if (nch.gt.2) nch=2
      call hol2char(ibuf,ic1,ic2,cid2)
      ierr=0

      return
      end
