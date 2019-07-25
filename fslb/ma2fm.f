      subroutine ma2fm(ibuf,inp,imod,irate,isyn,itst,isgn,irun, 
     .irem,ipwr,ialr)

C  convert mat buffer to fm data c#870407:12:41# 
C 
C     This routine converts the buffers returned from the MAT 
C     into the formatter information. 
C     **NOTE** Only the buffer with the date and miscellaneous
C     information is decoded. 
C 
C  INPUT: 
C 
      integer*2 ibuf(1) 
C      - buffers of length 5 words, as returned from MATCN
C 
C  OUTPUT:
C 
C     INP - input source
C     IMOD - mode 
C     IRATE - sample rate index 
C     ISYN - synch test setting 
C     ITST - synch test result
C     ISGN - sign of something
C     IRUN - status of run/set switch 
C     IREM - remote/local 
C     IPWR - power fail indicator 
C     IALR - alarm on/off 
C 
C 
C     Buffers from MATCN look like: 
C     for ( data:   FMhhmmssss (time word)
C     where each letter represents a character: 
C                   hh = hours
C                   mm = minutes
C                   ss = seconds
C                   ss = fractional seconds 
C 
C      ) data:      FMbydddpsr
C     where 
C                   b = bits denoting rem/lcl, alarm, power status
C                   y = years 
C                   ddd = days
C                   p = run/set, +/- edge, synch test bits
C                   s = input, output selection 
C                   r = rate setting
C     Note we are only concerned with the last 8 characters 
C 
C 
      inp = and(ia2hx(ibuf,9),12)/4
      imod = and(ia2hx(ibuf,9),3)
      irate = and(ia2hx(ibuf,10),7)
      isyn = and(ia2hx(ibuf,8),1)
      itst = and(ia2hx(ibuf,8),2)/2
      isgn = and(ia2hx(ibuf,8),4)/4
      irun = and(ia2hx(ibuf,8),8)/8
      irem = and(ia2hx(ibuf,3),4)/4
      ipwr = and(ia2hx(ibuf,3),1)
      ialr = and(ia2hx(ibuf,3),2)
C 
      return
      end 
