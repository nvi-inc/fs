      subroutine cants(itscb,ntscb,iflag,index,indts) 
C 
C  CANTS cancels entries depending on IFLAG 
C      1=cancel all procs from the station library
C      2=cancel all procs from the schedule library 
C      3=cancel everything initiated by the operator
C      4=cancel everything initiated by the schedule
C      5=cancel particular command as specified in INDEX,INDTS
C 
      dimension itscb(13,1) 
C 
      do 100 i=1,ntscb
        if (itscb(1,i).eq.-1) goto 100
        ilib = jchar(itscb(10,i),2) 
        isor = jchar(itscb(13,i),2) 
        go to (10,20,30,40,50) iflag
10      if (ichcm_ch(ilib,1,'Q').eq.0) goto 90
          go to 100 
20      if (ichcm_ch(ilib,1,'P').eq.0) goto 90
          go to 100 
30      if (ichcm_ch(isor,1,';').eq.0) goto 90
          go to 100 
40      if (ichcm_ch(isor,1,':').eq.0) goto 90
          go to 100 
50      if(itscb(11,i).ne.index) goto 100 
        if(indts.ne.-1.and.i.ne.indts) goto 100 
90      itscb(1,i) = -1 
        call clrcl(itscb(12,i)) 
100   continue
      return
      end 
