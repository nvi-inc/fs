      subroutine getts(itscb,ntscb,it,itype,index,iclass,lsor,indts,
     .klast,istksk,istkop)
C     GET NEXT TIME-SCHEDULED JOB FOR BOSS
      integer*4 itscb(13,1),it(9)
      integer istkop(1),istksk(1)
      logical klast
C                   TRUE IF THIS IS LAST TIME TO BE EXECUTED
      character cjchar
      integer*4 secsnow,secsmin,delta
      integer*4 itmina(3),itnow(3)
C
C     INITIALIZE
1     continue
      itype = 0
      index = 0
      iclass = 0
      itmin = 0
C                   INDEX OF EARLIEST TIME
      indts = 0
c not Y10K compliant
      itmina(1) = (10000-1970)*1024+365
      itmina(2) = 1440
      itmina(3) = 5999
C                   EARLIEST TIME FAR IN FUTURE FOR TESTING 
      call fc_rte_time(it,it(6))
      itnow(1)=(it(6)-1970)*1024+it(5)
      itnow(2)=it(4)*60+it(3)
      itnow(3)=it(2)*100+it(1)
c not Y2038 compliant
      call fc_rte2secs(it,secsnow)
      ihsnow=it(1)
C 
      do 100 i=1,ntscb
        if (itscb(1,i).eq.-1) goto 100
C                   SKIP THE EMPTY ENTRIES
        if(itscb(1,i).gt.itmina(1)) then
           goto 100
        else if(itscb(1,i).eq.itmina(1)) then
           if(itscb(2,i).gt.itmina(2)) then
              goto 100
           else if(itscb(2,i).eq.itmina(2)) then
              if(itscb(3,i).gt.itmina(3)) goto 100
           endif
        endif
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
 90     continue
        itmin = i 
        itmina(1)=itscb(1,i)
        itmina(2)=itscb(2,i)
        itmina(3)=itscb(3,i)
100     continue
C 
      if (itmin.ne.0) goto 200
C     NOTHING IS ON TIME LIST -- TELL BOSS TO SUSPEND FOR 5 MIN 
      call iadt(it,5,3)
      itmina(1)=(it(6)-1970)*1024+it(5)
      itmina(2)=it(4)*60+it(3)
      itmina(3)=it(2)*100+it(1)
      it(1) = itmina(1)
      it(2) = itmina(2)
      it(3) = itmina(3)
      return
C
C     WE HAVE FOUND SOMETHING TO DO!
 200  continue
      it(6)=itscb(1,itmin)/1024+1970
      it(5)=mod(itscb(1,itmin),1024)
      it(4)=itscb(2,itmin)/60
      it(3)=mod(itscb(2,itmin),60)
      it(2)=itscb(3,itmin)/100
      it(1)=mod(itscb(3,itmin),100)
c not Y2038 compliant
      call fc_rte2secs(it,secsmin)
      ihsmin=it(1)
      do i=1,9
        it(i) = itscb(i,itmin)
      enddo
c not Y2038 compliant
      delta=(secsmin-secsnow)*100+ihsmin-ihsnow
      if (delta.gt.2) return
      if (delta.gt.0) then
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
 300  continue
      if (it4.ne.3) goto 310
      it2 = it2 + it5 
      goto 320
c
 310  continue
      if (it4.eq.2) it3 = it3 + it5*100 
      if (it4.eq.1) it3 = it3 + it5
c
      if (it3.lt.6000) goto 400 
      it2 = it2 + it3 / 6000
      it3 = mod(it3, 6000)
c
 320  continue
      if (it2.lt.1440) goto 400 
      it1 = it1 + it2 / 1440
C not Y2.1k compliant
      if(mod(it1/1024+1970,4).eq.0) then
         if(mod(it1,1024).ge.367) then
            it1=it1-366+1024
         endif
      else if(mod(it1,1024).ge.366) then
         it1=it1-365+1024
      endif
      it2 = mod(it2, 1440)
      goto 320
C 
 400  continue
      if(it1.lt.itnow(1)) then
         goto 300
      else if(it1.eq.itnow(1)) then
         if(it2.lt.itnow(2)) then
            goto 300
         else if(it2.eq.itnow(2)) then
            if(it3.lt.itnow(3)) goto 300
         endif
      endif
c
      itscb(2,itmin) = it2
      itscb(1,itmin) = it1
      itscb(3,itmin) = it3
      itscb(4,itmin) = it4
      itscb(5,itmin) = it5
      itscb(7,itmin) = it7
      itscb(8,itmin) = it8
      itscb(9,itmin) = it9
      klast = .false. 
      if(it7.eq.0) goto 990
      if(it1.lt.itnow(1)) then
         goto 990
      else if(it1.eq.it7) then
         if(it2.lt.it8) then
            goto 990
         else if(it2.eq.it8) then
            if(it3.le.it9) goto 990
         endif
      endif
410   klast = .true.
      if (cjchar(itype,1).eq.'!') itscb(1,itmin) = -1
C                   Cancel now if this is a wait-for command
990   return
      end 
