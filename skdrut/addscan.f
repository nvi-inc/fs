      subroutine addscan(irec,istn,idur,ifeet,ipas,lcb,ierr)

C   ADDSCAN adds a new station to an existing scan.
C*** ib2as accepts only character indices up to 256

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/statn.ftni'

C History
C 960527 nrv New.

C Input
      integer irec ! record to add to
      integer istn ! station index
      integer idur ! duration
      integer ifeet ! footage
      integer ipas ! pass index
      integer*2 lcb ! cable

C Output
      integer ierr ! non-zero trouble

C Local
      integer*2 ibuf(ibuf_len)
      integer*2 ibufx(10) ! extended buffer
      integer nst,iblen,ich,nch,idum,i,ic1,ic2
      integer numc2,numc3,numc4,numc5
      integer ib2as,ichmv_ch,ichmv
      character*1 pnum ! function

      numc2 = 2+o'40000'+o'400'*2
      numc3 = 3+o'40000'+o'400'*3
      numc4 = 4+o'40000'+o'400'*4
      numc5 = 5+o'40000'+o'400'*5
      ierr=0

C 1. Get the record from common.

C     idum = ichmv(ibuf,1,lskobs(1,iskrec(irec)),1,ibuf_len*2)
C     write(6,'(i5)') irec
C 2. Find the place to put the new station id.
C     source cal code preob start duration midob idle postob scscsc pdfoot p
C     Example:
C     3C84      120 SX PREOB 800923120000  780 MIDOB    0 POSTOB K-F-G-OW 1F
C      1         2   3  4       5           6    7      8   9    10

      ich=1
      do i=1,10 ! skip over to station list
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      nst=(ic2-ic1+1)/2 ! number of stations so far
C     Add station code and cable wrap
      nch=ic2+1 ! start after the end of the station field
      NCH = ICHMV(lskobs(1,iskrec(irec)),NCH,LSTCOD(ISTN),1,1)
      NCH = ICHMV(lskobs(1,iskrec(irec)),NCH,LCB,1,1)
C     Skip each station's footage
      ich = nch
      do i=1,nst 
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-1 ! problem skipping footages
        return
      endif
C   Tape pass, direction, footage for each station
      nch = ic2+1 ! start at end of last footage
      NCH = ICHMV_ch(lskobs(1,iskrec(irec)),NCH+1,pnum(ipas))
      i=ipas/2
      if (ipas.eq.i*2) then ! even
        NCH = ICHMV_ch(lskobs(1,iskrec(irec)),NCH,'R')
      else
        NCH = ICHMV_ch(lskobs(1,iskrec(irec)),NCH,'F')
      endif
      NCH=  NCH+IB2AS(ifeet,lskobs(1,iskrec(irec)),NCH,numc5)
C   Skip procedure flags
      ich = nch 
      CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
C   Skip each station's duration
      do i=1,nst 
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-2 ! problem skipping durations
        return
      endif
C  Duration
      i = ib2as(idur,ibufx,1,5) ! convert into a buffer
      nch = ic2+1
      nch = ichmv(lskobs(1,iskrec(irec)),nch,ibufx,1,5)
C  Length of buffer
      iblen = nch/2
C
C Re-Store the record in common

C     DO I=1,IBLEN
C       LSKOBS(I,ISKREC(irec)) = IBUF(I)
C     END DO

      return
      end
