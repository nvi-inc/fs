      subroutine rp2ma4(ibuf,iby,ieq,ita,itb)

C  convert repro data to mat buffer c#870407:12:39# 
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffer for the formatted message for MATCN.
C        There are 9 characters returned
C     IBY - bypass code 
C     IEQ - equalizer selection 
C     ITA - track A to be reproduced
C     ITB - track B to be reproduced
C 
C 
C     1. The format of the tape drive control word which sets 
C     up the tracks to be reproduced is:
C 
C     bit 31,30 =
C            29 = master reset
C         26-28 = 0
C            25 = Bypass mode
C         22-24 = 0
C         20-21 = Equalizer selection (0,1,2,3)
C         16-19 = 0
C         14-15 = Channel B stack select
C          8-13 = Channel B head select
C          6-7  = Channel A stack select
C          0-5  = Channel A head select
C 
      nch = ichmv_ch(ibuf,1,'+')
C                   The strobe character
      nch = ichmv_ch(ibuf,nch,'0')
      nch = nch + ib2as(iby*2,ibuf,nch,1) 
      nch = nch + ib2as(ieq,ibuf,nch,1) 
      nch = ichmv_ch(ibuf,nch,'0')

      ibit1415=0 
      if (itb.ge.100) ibit1415=JISHFT((itb/100),2)
      itens = MOD(itb,100)
      ibit1213 = itens/16 
      call ichmv(ibuf,nch,ihx2a(or(ibit1415,ibit1213)),2,1)
      nch=nch+1
      ibit811 = itens - (ibit1213*16)
      call ichmv(ibuf,nch,ihx2a(ibit811),2,1)
      nch=nch+1

      ibit67=0 
      if (ita.ge.100) ibit67=JISHFT((ita/100),2)
      itens = MOD(ita,100)
      ibit45 = itens/16 
      call ichmv(ibuf,nch,ihx2a(or(ibit67,ibit45)),2,1)
      nch=nch+1
      ibit03 = itens - (ibit45*16)
      call ichmv(ibuf,nch,ihx2a(ibit03),2,1)
      nch=nch+1
C 
      return
      end 
