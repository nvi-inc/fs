      function ifmed(iwhat,index,ias,ic1,ic2)

C     This routine encodes or decodes information relating
C     to MAT communications for the formatter 
C 
C  INPUT: 
C 
C     IWHAT - code for type of conversion, <0 encode, >0 decode 
      integer*2 ias(1)
C      - string with ASCII characters 
C 
C 
C  If encode
C 
C     INDEX - input index of quantity 
C     IAS - string to hold ASCII characters 
C     IC1 - first char available in IAS 
C     IC2 - last char available in IAS
C     IFMED - next available char in IAS after encoding 
C 
C  If decode: 
C 
C     INDEX - returned index of quantity, error if zero 
C     IAS - string containing ASCII characters to be decoded
C     IC1 - first char to use in IAS
C     IC2 - last char to use in IAS 
C 
C 
C  SUBROUTINES called: character manipulation 
C 
C 
C  LOCAL: 
C 
      double precision das2b
      integer*2 lset(3),lsyn(2)
      integer*2 lrem(4), lpwr(2), ltest(3)
      integer*2 linps(5),lmodes(4),lsign
      dimension rates(8) 
      dimension ntest(2),npwr(2),nrem(2)
      data rates/8.0,0.0,0.125,0.25,0.5,1.0,2.0,4.0/
      data lrem/2Hre,2Hm ,2Hlo,2Hc /
      data nrem/3,3/ 
      data lpwr/2Hok,2Hpw/
      data npwr/2,2/ 
      data lsign/2h-+/
      data lset/2hru,2hns,2het/ 
      data ltest/2Hok,2Hfa,2Hil/
      data ntest/2,4/
      data lsyn/2hof,2hon/
      data linps/2hno,2hre,2hxt,2hcr,2hc /
      data lmodes/2hab,2hcd,2h  ,2h  /
      data nrates/8/
C 
C     1. Initialize returned parameter in case we have to quit early. 
C 
      ifmed = ic1 
      if (iwhat.gt.0) index = -1
C 
      goto (209,208,207,206,205,204,203,202,201,990,
     .301,302,303,304) iwhat+10 
C 
C     2.01 Code -1, MODE
C 
201   if (ic1+1.gt.ic2) return
      ifmed = ichmv(ias,ic1,lmodes,1+index,1) 
      return
C 
C     2.02 Code -2, SAMPLE RATE 
C 
202   continue
      if (ic1-1+5.gt.ic2) return
      ifmed = ic1 + ir2as(rates(index+1),ias,ic1,5,3) 
      return
C 
C     2.03 Code -3, General LOCAL/REMOTE. 
C 
203   continue
      if (ic1-1+nrem(index+1).gt.ic2) return
      ifmed = ichmv(ias,ic1,lrem,index*4+1,nrem(index+1)) 
      return
C 
C     2.04 Code -4, SYNCH TEST ON/OFF 
C 
204   continue
      if (ic1-1+2.gt.ic2) return
      ifmed = ichmv(ias,ic1,lsyn,index*2+1,2) 
      return
C 
C     2.05 Code -5, SYNCH TEST PASS/FAIL
C 
205   continue
      if (ic1-1+ntest(index+1).gt.ic2) return 
      ifmed = ichmv(ias,ic1,ltest,index*2+1,ntest(index+1)) 
      return
C 
C     2.06 Code -6, SIGN OF SYNCH TEST
C 
206   continue
      if (ic1.gt.ic2) return
      ifmed = ichmv(ias,ic1,lsign,index+1,1)
      return
C 
C     2.07 Code -7, RUN/SET 
C 
207   continue
      if (ic1+2.gt.ic2) return
      ifmed = ichmv(ias,ic1,lset,index*3+1,3) 
      return
C 
C     2.08 Code -8, INPUT SELECTION 
C 
208   continue
      if (ic1+2.gt.ic2) return
      ifmed = ichmv(ias,ic1,linps,index*3+1,3)
      return
C 
C     2.09 Code -9, POWER INTERRUPT 
C 
209   continue
      if (ic1-1+npwr(index+1).gt.ic2) return
      ifmed = ichmv(ias,ic1,lpwr,index*2+1,npwr(index+1)) 
      return
C 
C     3. Initialize for the DECODE case.
C 
C     3.01 FORMATTER MODES
C 
301   continue
      do 3010 i=1,4 
        if (jchar(ias,ic1).eq.jchar(lmodes,i)) index=i-1
3010    continue
      return
C 
C     3.02 SAMPLE RATES 
C 
302   continue
      val = das2b(ias,ic1,ic2-ic1+1,ierr) 
      if (ierr.ne.0) return 
      do 3020 i=1,nrates
        if (val.eq.rates(i)) index = i-1
3020    continue
      return
C 
C     3.03 INPUT SELECTION
C 
303   continue
      do 3030 i=1,3 
        if (ichcm(ias,ic1,linps,(i-1)*3+1,3).eq.0) index = i-1
3030    continue
      return
C 
C     3.04 SYNCH TEST ON/OFF
C 
304   continue
      do 3040 i=1,2 
        if (ichcm(ias,ic1,lsyn(i),1,2).eq.0) index=i-1
3040    continue
      return
C 
990   return
      end 
