      subroutine addscan(irec,istn,icod,idstart,idend,
     .ifeet,ipas,idrive,lcb,ierr)

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

C Input
      integer irec ! record to add to
      integer istn ! station index
      integer icod ! frequency code index
      integer idend ! duration
      integer idstart ! start of good data
      integer ifeet ! footage
      integer ipas ! pass index
      integer idrive ! which recorder, 0=no record
      integer*2 lcb ! cable

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
      NCH = ICHMV(lskobs(1,iskrec(irec)),NCH,LSTCOD(ISTN),1,1)
      NCH = ICHMV(lskobs(1,iskrec(irec)),NCH,LCB,1,1)
C     Skip previous stations' footage
      ich = nch
      do i=1,nst 
        CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      if (ic1.eq.0) then
        ierr=-1 ! problem skipping footages
        return
      endif
      nch=ic2+2
C   Tape pass, direction, footage for each station
C ** why not use cpassorderl for all stations not just S2?
C ** because FS uses pass numbers not index positions
      nch = feetscan(lskobs(1,iskrec(irec)),nch,ipas,ifeet,idrive,
     .istn,icod)
C     if (ichcm_ch(lstrec(1,istn),1,'S2').eq.0) then
C       kfor=.true. ! always forward
C       cgroup=cpassorderl(ipas,istn,icod)(1:1) ! group number
C       nch=ichmv_ch(lskobs(1,iskrec(irec)),nch+1,cgroup)
C     else
C       NCH = ICHMV_ch(lskobs(1,iskrec(irec)),NCH+1,pnum(ipas))
C       i=ipas/2
C       kfor= ipas.ne.i*2 ! odd forward, even reverse = VEX standard
C     endif
C     if (kfor) cdir='F'
C     if (.not.kfor) cdir='R'
C     if (idrive.eq.0) cdir='0'
C     NCH = ICHMV_ch(lskobs(1,iskrec(irec)),NCH,cdir)
C  Put in footage. For S2 this is in seconds.
C     NCH=  NCH+IB2AS(ifeet,lskobs(1,iskrec(irec)),NCH,numc5)
C   Skip procedure flags
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
      nch=ich+2
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
