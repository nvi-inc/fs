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
      integer*2 ibufx(ibuf_len) ! extended buffer
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

      idum = ichmv(ibuf,1,lskobs(1,iskrec(irec)),1,ibuf_len*2)

C 2. Find the place to put the new station id.
C     source cal code preob start duration midob idle postob scscsc pdfoot p
C     Example:
C     3C84      120 SX PREOB 800923120000  780 MIDOB    0 POSTOB K-F-G-OW 1F
C      1         2   3  4       5           6    7      8   9    10

      ich=1
      do i=1,10 ! skip over to station list
        CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      nst=(ic2-ic1+1)/2 ! number of stations so far
C     Add station code and cable wrap
      nch=ic2+1 ! start after the end of the station field
      NCH = ICHMV(IBUF,NCH,LSTCOD(ISTN),1,1)
      NCH = ICHMV(IBUF,NCH,LCB,1,1)
C     Skip each station's footage
      ich = nch
      do i=1,nst 
        CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-1 ! problem skipping footages
        return
      endif
C   Tape pass, direction, footage for each station
      nch = ic2+1 ! start at end of last footage
      NCH = ICHMV_ch(IBUF,NCH+1,pnum(ipas))
      i=ipas/2
      if (ipas.eq.i*2) then ! even
        NCH = ICHMV_ch(IBUF,NCH,'R')
      else
        NCH = ICHMV_ch(IBUF,NCH,'F')
      endif
      NCH=  NCH+IB2AS(ifeet,IBUF,NCH,numc5)
C   Skip procedure flags
      ich = nch 
      CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
C   Skip each station's duration
      do i=1,nst 
        CALL GTFLD(IBUF,ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-2 ! problem skipping durations
        return
      endif
C  Duration
      i = ib2as(idur,ibufx,1,5) ! convert into a buffer
      nch = ic2+1
      nch = ichmv(ibuf,nch,ibufx,1,5)
C     NCH = 1 + NCH + IB2AS(IDUR,IBUF,NCH+1,5)
C  Length of buffer
      iblen = nch/2
C
C Re-Store the record in common

      DO I=1,IBLEN
        LSKOBS(I,ISKREC(irec)) = IBUF(I)
      END DO

      return
      end
