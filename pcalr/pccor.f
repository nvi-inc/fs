      subroutine pccor(ivc,ivc2,itrk,kcorel,idata,ilog,r1bit, 
     . nzero)
C 
C     This routine first checks to see that the split mode data 
C     comes from VC's on the same frequency and side band, and
C     then checks to see if the data streams are the same.
C 
C  INPUT: 
C     IVC - first VC
C     IVC2 - second VC
C     ITRK - track on first VC
      logical kcorel
C      - true if data was correlated
      dimension idata(1)
C      - holds the data 
C     ILOG - length of IDATA in chars 
C 
C  OUTPUT:
C     R1BIT - number of bits counted
C     NZERO - number of non-matching bits 
C 
      include '../include/fscom.i'
C 
      kcorel = .false.
      if (freqvc(ivc).ne.freqvc(ivc2)) goto 990 
      lsb1 = itr2vc(itrk,imodfm+1)
      lsb2 = itr2vc(itrkpc(itrk),imodfm+1)
      if ((lsb1.gt.0.and.lsb2.lt.0).or.(lsb1.lt.0.and.lsb2.gt.0)) 
     . goto 990 
C 
      do 150 i = 1,ilog/4 
          r1bit = r1bit+16
          if (idata(i).eq.idata(i+128)) goto 150
          ibit = and(idata(i),idata(i+128))
          nzero = nzero+(16-i1bit(ibit))
150       continue
      kcorel = .true. 
C 
990   continue

      return
      end 
