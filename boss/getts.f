      subroutine getts(itscb,ntscb,it,itype,index,iclass,lsor,indts,
     .klast,istksk,istkop)
C     GET NEXT TIME-SCHEDULED JOB FOR BOSS
      dimension itscb(13,1),it(9),istkop(1),istksk(1)
      double precision t1,tnow,t2,tmin
      logical klast,kstak
C                   TRUE IF THIS IS LAST TIME TO BE EXECUTED
      character cjchar
C
C     INITIALIZE
1     continue
      itype = 0
      index = 0
      iclass = 0
      itmin = 0
C                   INDEX OF EARLIEST TIME
      indts = 0
      tmin = 1.0d9
C                   EARLIEST TIME FAR IN FUTURE FOR TESTING 
      call fc_rte_time(it,idum)
      tnow = 86400.d0*it(5)+it(4)*3600.d0+it(3)*60.d0+it(2)+it(1)/100.d0
C 
      do 100 i=1,ntscb
        if (itscb(1,i).eq.-1) goto 100
C                   SKIP THE EMPTY ENTRIES
        t1 = 86400.d0*mod(itscb(1,i),1024)
     .       +itscb(2,i)*60.d0 + itscb(3,i)/100.d0
        if (t1.ge.tmin) goto 100
        itt = jchar(itscb(10,i),2)
        if (ichcm_ch(itt,1,'P').ne.0.and.
     .      ichcm_ch(itt,1,'Q').ne.0) goto 90
C                     If this isn't a time-scheduled proc,
C                     don't worry about checking stacks 
        ict = jchar(itscb(13,i),2)
C                     This is the command stream, schedule or operator
        if (ichcm_ch(ict,1,';').eq.0.and.istkop(2).ne.2) goto 100 
        if (ichcm_ch(ict,1,':').eq.0.and.istksk(2).ne.2) goto 100 
C                     If this is a time-scheduled procedure and the 
C                     stream/stack onto which it wants to be
C                     pushed has something in it, then ignore 
C                     for now.
90      itmin = i 
        tmin = t1 
100     continue
C 
      if (itmin.ne.0) goto 200
C     NOTHING IS ON TIME LIST -- TELL BOSS TO SUSPEND FOR 5 MIN 
      it(1) = it(5)
      is = it(2)
      it(2) = it(4)*60 + it(3) + 5
      it(3) = is * 100
      return
C
C     WE HAVE FOUND SOMETHING TO DO!
200   do 210 i=1,9
        it(i) = itscb(i,itmin)
210     continue
      if (tmin.gt.tnow+0.025d0) return
      if (tmin.gt.tnow+0.005d0) then
        call susp(1,1)
        goto 1
      endif
C                   IF EARLIEST JOB IS IN FUTURE, HAVE BOSS SUSPEND TILL THEN
C
      itype = itscb(10,itmin)
      index = itscb(11,itmin)
      iclass = itscb(12,itmin)
      lsor = itscb(13,itmin)
      indts = itmin
      it2 = itscb(2,itmin)
      it1 = itscb(1,itmin)
      it3 = itscb(3,itmin)
      it4 = itscb(4,itmin)
      it5 = itscb(5,itmin)
      it7 = itscb(7,itmin)
      it8 = itscb(8,itmin)
      it9 = itscb(9,itmin)
      if (it4.eq.0) goto 410
C                   If once-only, mark as "last time" 
C     INCREMENT TO NEXT EXECUTION TIME
300   if (it4.ne.3) goto 310
      it2 = it2 + it5 
      goto 320
310   if (it4.eq.2) it3 = it3 + it5*100 
      if (it4.eq.1) it3 = it3 + it5 
      if (it3.lt.6000) goto 400 
      it3 = it3 - 6000
      it2 = it2 + 1 
320   if (it2.lt.1440) goto 400 
      it2 = it2 - 1440
      it1 = it1 + 1 
C 
400   t1 = 86400.d0*mod(it1,1024) +it2*60.d0 + it3/100.d0 
      if (t1.lt.tnow) goto 300
      t2 = 86400.d0*mod(it7,1024) +it8*60.d0 + it9/100.d0 
      if (it7.eq.0) t2 = 1.0d9
      itscb(2,itmin) = it2
      itscb(1,itmin) = it1
      itscb(3,itmin) = it3
      itscb(4,itmin) = it4
      itscb(5,itmin) = it5
      itscb(7,itmin) = it7
      itscb(8,itmin) = it8
      itscb(9,itmin) = it9
      klast = .false. 
      if (t1.le.t2) goto 990
410   klast = .true.
      if (cjchar(itype,1).eq.'!') itscb(1,itmin) = -1
C                   Cancel now if this is a wait-for command
990   return
      end 
