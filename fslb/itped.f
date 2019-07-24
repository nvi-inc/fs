      function itped(iwhat,index,ias,ic1,ic2)

C  This routine encodes or decodes information relating
C  to MAT communications for the tape drive
C 
C  INPUT: 
C 
C     IWHAT - code for type of conversion, <0 encode, >0 decode 
      integer*2 ias(20) 
C      - string with ASCII characters 
C 
C 
C  If encode
C 
C     INDEX - input index of quantity 
C     IAS - string to hold ASCII characters 
C     IC1 - first char available in IAS 
C     IC2 - last char available in IAS
C     ITPED - next available char in IAS after encoding 
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
      integer*2 lfast(4),lcaps(7),lstop(5),ltach(6)
      integer*2 ldir(3),llow(3),lreset(5),lrec(3)
      integer itsp(8)
      dimension nready(2),ncaps(2),nstop(2),nrem(2),nrec(2) 
      integer*2 lrem(4), lready(7)
C 
C  INITIALIZED: 
C 
      data itsp/0,3,7,15,30,60,120,240/ 
      data nsp/8/ 
      data lrem   /2Hre,2Hm ,2Hlo,2Hc /
      data nrem/3,3/ 
      data lfast  /2Hno,2Hrm,2Hfa,2Hst/ 
      data lcaps  /2Hst,2Hop,2Hpe,2Hdm,2Hov,2Hin,2Hg /
      data lstop  /2Hno,2Hst,2Hop,2Hst,2Hop/
      data ltach  /2Hun,2Hlo,2Hck,2Hlo,2Hck,2Hed/ 
      data lready/2Hre,2Had,2Hy ,2Hno,2Htr,2Hea,2Hdy/
      data nready/5,8/ 
      data ldir   /2Hre,2Hvf,2Hor/
      data llow   /2Hof,2Hfl,2How/
      data lreset /2H  ,2H  ,2H r,2Hes,2Het/
      data lrec /2Hof,2Hfo,2Hn /
      data ncaps/7,6/ 
      data nstop/6,4/ 
      data nrec /3,2/ 
C 
C 
C  Initialize returned parameter in case we have to quit early. 
C 
      itped = ic1 
      if (iwhat.gt.0) index = -1
C 
      goto (210,209,208,207,206,205,204,203,202,201,
     .      990,301,302,303,304,305) iwhat+11 
C 
C  Code -1, tape speed. 
C 
201   continue
C     IF (IWHAT.NE.-1) GOTO 202 
      if (ic1-1+3.gt.ic2) return
      itped = ic1 + ib2as(itsp(index+1),ias,ic1,o'100000'+3)
      return
C 
C  Code -2, tape direction. 
C 
202   continue
C     IF (IWHAT.NE.-2) GOTO 203 
      if (ic1-1+3.gt.ic2) return
      itped = ichmv(ias,ic1,ldir,index*3+1,3) 
      return
C 
C  Code -3, LOCAL/REMOTE. 
C 
203   continue
C     IF (IWHAT.NE.-3) GOTO 204 
      if (ic1-1+nrem(index+1).gt.ic2) return
      itped = ichmv(ias,ic1,lrem,index*4+1,nrem(index+1)) 
      return
C 
C  Code -4, TACH LOCK/UNLOCK. 
C 
204   continue
C     IF (IWHAT.NE.-4) GOTO 205 
      if (ic1-1+6.gt.ic2) return
      itped = ichmv(ias,ic1,ltach,index*6+1,6)
      return
C 
C  Code -5, low tape sensor.
C 
205   continue
C     IF (IWHAT.NE.-5) GOTO 206 
      if (ic1-1+3.gt.ic2) return
      itped = ichmv(ias,ic1,llow,index*3+1,3) 
      return
C 
C  Code -6, fast speed. 
C 
206   continue
C     IF (IWHAT.NE.-6) GOTO 207 
      if (ic1-1+4.gt.ic2) return
      itped = ichmv(ias,ic1,lfast,index*4+1,4)
      return
C 
C  Code -7, stop command
C 
207   continue
C     IF (IWHAT.NE.-7) GOTO 208 
      if (ic1-1+nstop(index+1).gt.ic2) return 
      itped = ichmv(ias,ic1,lstop,index*6+1,nstop(index+1)) 
      return
C 
C  Code -8, vacuum ready
C 
208   continue
C     IF (IWHAT.NE.-8) GOTO 209 
      if (ic1-1+nready(index+1).gt.ic2) return
      itped = ichmv(ias,ic1,lready,index*6+1,nready(index+1)) 
      return
C 
C  Code -9, capstan status
C 
209   continue
C     IF (IWHAT.NE.-9) GOTO 300 
      if (ic1-1+ncaps(index+1).gt.ic2) return 
      itped = ichmv(ias,ic1,lcaps,index*7+1,ncaps(index+1)) 
      return
C 
C  Code -10, record status
C 
210   continue
      if (ic1-1+nrec(index+1).gt.ic2) return
      itped = ichmv(ias,ic1,lrec,index*3+1,nrec(index+1)) 
      return
C 
C 
C  Initialize for the DECODE case.
C 
C     INDEX = -1
C 
C 
C  TAPE SPEEDS
C 
301   continue
      ii = ias2b(ias,ic1,ic2-ic1+1) 
      if (ii.eq.-32768) return
      do 3010 i=1,nsp 
        if (ii.eq.itsp(i)) index = i-1
3010    continue
      return
C 
C 
C  TAPE DIRECTIN
C 
302   continue
C     IF (IWHAT.NE.+2) GOTO 303 
      do 3020 i=1,2 
        if (ichcm(ias,ic1,ldir,(i-1)*3+1,3).eq.0) index = i-1 
3020    continue
      return
C 
C  LOW TAPE SENSOR
C 
303   continue
C     IF (IWHAT.NE.+3) GOTO 304 
      do 3030 i=1,2 
        if (ichcm(ias,ic1,llow,(i-1)*3+1,3).eq.0) index=i-1 
3030    continue
      return
C 
C  RESET FOOTAGE COUNTER
C 
304   continue
C      IF (IWHAT.NE.+4) GOTO 990
      do 3040 i=1,2 
        if (ichcm(ias,ic1,lreset,(i-1)*5+1,5).eq.0) index=i-1 
3040    continue
C 
C  Record status
C 
305   continue
      do 3050 i=1,2 
        if (ichcm(ias,ic1,lrec,(i-1)*3+1,nrec(i)).eq.0) index = i-1 
3050  continue

990   return
      end 
