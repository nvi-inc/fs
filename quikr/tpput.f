      subroutine tpput(ip,itpis,isub,ibufr,nch,ilenr) 
C 
C     TPPUT gets data from the TPIs and puts it into COMMON 
C     Also, formats response with these values. 
C 
C     DATE   WHO CHANGES
C     810913 NRV ADDED FORMATTING OF RESPONSE VALUES
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - # records in class
C        IP(3)  - error return from MATCN 
      integer itpis(1)
C      - TPI selection
C     ISUB - which sub-function, 3=TPI, 4=TPICAL, 7=TPZERO
C     IBUFR - buffer with first part of response in it
C     NCH - next available character in IBUFR 
C     ILENR - length of IBUFR 
      integer*2 ibufr(1)
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) -
C        IP(2) -
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
C 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C 
C 3.  LOCAL VARIABLES 
C 
      integer*4 freq
      integer*4 isw(4)
      dimension ld(3) 
C      - dummy for VC conversion
      dimension tret(2)
C      - temporary TP variables 
      parameter (ibufln=15)
      integer*2 ibuf(ibufln),ibufd(ibufln)
C               - input class buffers with MATCN responses
C               - registers from EXEC 
      dimension ireg(2) 
      integer get_buf
      equivalence (reg,ireg(1)) 
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ibufd/15*2H00/
C 
C 
C     PROGRAM STRUCTURE 
C 
C     1. Step through the TPIs requested which we assume correspond
C     to the responses from MATCN.  Put the TPs into COMMON.
C
      ncrec = ip(2)
      iclass = ip(1)
      nr = 0
      it = 0
      ierr = 0
      do 190 i=1,17
        if (itpis(i).eq.0) goto 190
        if (nr.gt.ncrec) goto 190
        if (nr.eq.ncrec) goto 120
C                     This is the case when both IFs were asked for
        nr = nr + 1
        call ifill_ch(ibuf,1,ibufln*2,' ')
        ireg(2) = get_buf(iclass,ibuf,-10,idum,idum)
        if (i.gt.14) goto 120
        call ma2vc(ibuf,ibuf,ld,id,itp,id,id,id,id,tret,id)
        if (itp.ne.1.and.itp.ne.2) tret(1)=-1.0
C                     If not a valid TPI, set reading to -1
        if (tret(1).eq.65535.) tret(1)=1.d9
C                     If overflow, indicate by $$$$
        nch = nch + ir2as(tret,ibufr,nch,6,0)-1
        nch = mcoma(ibufr,nch)
C                     Put the value into the response 
        ii = i+(itp-1)*14 
        if (ii.le.0.or.ii.gt.28) goto 190 
        if (isub.eq.3) tpsor(ii) = tret(1)
        if (isub.eq.4) tpspc(ii) = tret(1)
        if (isub.eq.7) tpzero(ii) = tret(1) 
        it = 1
        goto 190
120     continue
        if (i.gt.16) goto 130
        call ma2if(ibufd,ibuf,id,id,id,id,tret(1),tret(2),id)
        if (i.eq.16) tret(1) = tret(2)
        if (tret(1).eq.65535.) tret(1)=1.d9
C                     For IF2, pick up second value 
        if (isub.eq.3) tpsor(i+14)=tret(1)
        if (isub.eq.4) tpspc(i+14)=tret(1)
        if (isub.eq.7) tpzero(i+14)=tret(1) 
        it = 1
        nch = nch + ir2as(tret,ibufr,nch,6,0)-1
        nch = mcoma(ibufr,nch)
        goto 190
c
130     continue
        call ma2i3(ibufd,ibuf,iat,imix,isw(1),isw(2),isw(3),isw(4),
     &                ipcalp,iswp,freq,irem,ipcal,ilo,tret(1))
        if (isub.eq.3) tpsor(i+14)=tret(1)
        if (isub.eq.4) tpspc(i+14)=tret(1)
        if (isub.eq.7) tpzero(i+14)=tret(1) 
        it = 1
        nch = nch + ir2as(tret,ibufr,nch,6,0)-1
        nch = mcoma(ibufr,nch)
190     continue
C 
      if (it.eq.0) ierr = -1
C 
      nch = nch-2 
980   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qk',ip(4),1,2)
      ip(5) = 0 
      return
      end 
