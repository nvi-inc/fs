      subroutine en2ma(ibuf,iena,itrk,ltrk)
C     convert en data to mat buffer c#870407:12:39#
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer to be formatted 
      dimension itrk(1) 
C      - tracks to be encoded 
      dimension ltrk(1) 
C      - optional already-encoded tracks
C***NOTE*** LTRK will be used instead of ITRK if ITRK=-1
C     IENA - record-enable bit
C 
C  LOCAL: 
C 
      dimension ibit(28)
C               - which bit in control word corresponds to track
      data ibit/0,8,1,9,2,10,3,11,4,12,5,13,6,14, 
     .          16,24,17,25,18,26,19,27,20,28,21,29,22,30/
C 
C 
C     Format the buffer for the controller. 
C     The buffer is set up as follows:
C                   %xxxxxxxx 
C     where each x represents a group of tracks.
C 
      call ichmv(ibuf,1,2H% ,1,1) 
C                   The strobe character for this control word
      if (itrk(1).eq.-1) goto 150
C 
      call ichmv(ibuf,2,8H00000000,1,8) 
C                   Fill buffer with zeros to start 
      do 100 i=1,28 
        if (itrk(i).ne.1) goto 100
        ia = ia2hx(ibuf,9-ibit(i)/4)
C                   Pick out the proper character for this track
        ib = 2**(ibit(i)-(ibit(i)/4)*4) 
        ia = ior(ia,ib) 
        call ichmv(ibuf,9-ibit(i)/4,ihx2a(ia),2,1)
C                   Put back into place 
100     continue
      goto 200
C 
150   call ichmv(ibuf,2,ltrk,1,8) 
C 
200   ia = ior(ia2hx(ibuf,2),iena*8)
      call ichmv(ibuf,2,ihx2a(ia),2,1)
C                   Add in top bit with general enable
C 
      return
      end 
