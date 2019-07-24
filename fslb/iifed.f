      function iifed(iwhat,index,ias,ic1,ic2)

C     This routine encodes or decodes information relating
C     to MAT communications for the IF distributor
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
C     IIFED - next available char in IAS after encoding 
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
      integer*2 lrem(4)
      dimension nrem(2)
      integer*2 linps(3)
      data lrem/2hlo,2hc ,2hre,2hm /
      data nrem/3,3/ 
      data linps/2Hno,2Hra,2Hlt/
C 
C 
C     1. Initialize returned parameter in case we have to quit early. 
C 
      iifed = ic1 
      if (iwhat.gt.0) index = -1
C 
      goto (202,201,990,301) iwhat+3
C 
C     2.01 Code -1, INPUT ALT/NOR 
C 
201   if (ic1+2.gt.ic2) return
      iifed = ichmv(ias,ic1,linps,1+3*index,3)
      return
C 
C     2.02 Code -2, LOCAL/REMOTE. 
C 
202   continue
      if (ic1-1+nrem(index+1).gt.ic2) return
cxx      iifed = ichmv(ias,ic1,lrem,index*12+1,nrem(index+1))
      iifed = ichmv(ias,ic1,lrem,index*4+1,nrem(index+1))
      return
C 
C     3. Initialize for the DECODE case.
C 
C     3.01 INPUT NOR/ALT
C 
301   continue
      do 3010 i=1,2 
        if (ichcm(ias,ic1,linps,(i-1)*3+1,3).eq.0) index = i-1
3010    continue
      return

990   return
      end 
