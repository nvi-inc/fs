      function iif3ed(iwhat,index,ias,ic1,ic2)
c
C     This routine encodes or decodes information relating
C     to MAT communications for the IF3 distributor
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
C     IIF3ED - next available char in IAS after encoding 
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
      integer*2 lrem(3),lin(6),lpres(7),llck(4)
      integer nrem(2),nin(4),npres(2),nlck(2)
      data lrem/2hlo,2hcr,2hem/
      data lin/2H00,2H i,2Hn ,2Hou,2Ht1,2H1 /
      data lpres/2Hmi,2Hss,2Hin,2Hgp,2Hre,2Hse,2Hnt/
      data llck/2Hun,2Hlk,2Hlo,2Hck/
      data nrem/3,3/,nin/2,2,3,2/,npres/7,7/,nlck/4,4/
C 
C 
C     1. Initialize returned parameter in case we have to quit early. 
C 
      iif3ed = ic1 
      if (iwhat.gt.0) index = -1
C 
      goto (204,203,202,201,990,301) iwhat+5
C 
C     2.01 Code -1, mixer state
C 
201   continue
      if (index.lt.0) return
      if (ic1-1+nin(index+1).gt.ic2) return
      iif3ed = ichmv(ias,ic1,lin,1+3*index,nin(index+1))
      return
C  
C     2.02 Code -2, switch present or missing
C 
202   continue
      if (ic1-1+npres(index+1).gt.ic2) return
      iif3ed = ichmv(ias,ic1,lpres,index*7+1,npres(index+1))
      return
C  
C     2.02 Code -3, LOCAL/REMOTE. 
C 
203   continue
      if (ic1-1+nrem(index+1).gt.ic2) return
      iif3ed = ichmv(ias,ic1,lrem,index*3+1,nrem(index+1))
      return
C  
C     2.02 Code -4, lock/unlock. 
C 
204   continue
      if (ic1-1+nlck(index+1).gt.ic2) return
      iif3ed = ichmv(ias,ic1,llck,index*4+1,nlck(index+1))
      return
C 
C     3. Initialize for the DECODE case.
C 
C     3.01 mixer out/in
C 
301   continue
      do 3010 i=2,3
        if (ichcm(ias,ic1,lin,(i-1)*3+1,nin(i)).eq.0) index = i-1
3010    continue
      return

990   return
      end 
