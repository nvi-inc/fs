      subroutine addscan(irec,istn,icod,idstart,idend,
     .ifeet,ipas,idrive,cbl,ierr)

C   ADDSCAN adds a new station to an existing scan.
C*** ib2as accepts only character indices up to 256

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'

C History
C 960527 nrv New.
C 970214 nrv Update the feet/pass information for S2.
C            Add icod to call.
C 970721 nrv Add idrive to call
C 970721 nrv Remove footage, duration, and idstart to subroutines.
C 971003 nrv Move over one more character after finding the last footage.
C 001027 nrv Only leave 1 space between footages.

C Input
      integer irec ! record to add to
      integer istn ! station index
      integer icod ! frequency code index
      integer idend ! duration
      integer idstart ! start of good data
      integer ifeet ! footage
      integer ipas ! pass index
      integer idrive ! which recorder, 0=no record
      character*1 cbl

C Output
      integer ierr ! non-zero trouble

C Local
      integer nst,ich,nch,i,ic1,ic2
      integer ichmv
      integer feetscan,gdscan,durscan

      ierr=0

C 1. Get the record from common.

C     idum = ichmv(ibuf,1,lskobs(1,iskrec(irec)),1,ibuf_len*2)
C     write(6,'(i5)') irec
C 2. Find the place to put the new station id.
C     source cal code preob start duration midob idle postob scscsc pdfoot.. gd..
C     Example:
C      3C84      120 SX PREOB 800923120000  780 MIDOB    0 POSTOB K-F-G-OW 1F
Cfield: 1         2   3  4       5           6    7      8   9    10
C                            note direction=0 for a non-recording scan      ^

      ich=1
      do i=1,10 ! skip over to station list
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      nst=(ic2-ic1+1)/2 ! number of stations so far
C     Add station code and cable wrap
      nch=ic2+1 ! start after the end of the station field
      cskobs(iskrec(irec))(nch:nch+1)=cstcod(istn)//cbl
      nch=nch+2
C     Skip previous stations' footage
      ich = nch
      do i=1,nst 
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-1 ! problem skipping footages
        return
      endif
C     nch=ic2+2
C     Only leave 1 space between footages.
      nch=ic2+1
C   Tape pass, direction, footage for each station
C ** why not use cpassorderl for all stations not just S2?
C ** because FS uses pass numbers not index positions
      nch = feetscan(lskobs(1,iskrec(irec)),nch,ipas,ifeet,idrive,
     .istn,icod)
      ich = nch
      CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
C   Skip previous stations' duration
      do i=1,nst 
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-2 ! problem skipping durations
        return
      endif
C     Only leave 1 space between durations
      nch=ich+1
C  Duration
      nch = durscan(lskobs(1,iskrec(irec)),nch,idend)
C     i = ib2as(idend,ibufx,1,5) ! convert into a buffer
C     nch = ic2+1
C     nch = ichmv(lskobs(1,iskrec(irec)),nch,ibufx,1,5)
C   Skip previous stations' good data offsets
      ich = nch 
      do i=1,nst 
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-3 ! problem skipping data offsets
        return
      endif
      nch=ich+2
C  Good data offset
      nch = gdscan(lskobs(1,iskrec(irec)),nch,idstart)
C
      return
      end
