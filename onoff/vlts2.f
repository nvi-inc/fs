      subroutine vlts2(tpia,sig,tima,intp,rut,ierr) 
      dimension tpia(2),sig(2)
C 
C   TOTAL POWER INTEGERATION ROUTINE, THIS ROUTINE READS THE TPI
C       FOR THE SPECIFIED DEVICE
C 
C   INPUT:
C 
C       INTP   - INTEGRATION PERIOD IN SECONDS
C 
C       NTRY   - EXTRA TRIES TO ALLOW, IF AN ERROR OCCURS 
C 
C       RUT    - REFERENCE UT TIME OF DAY IS SECONDS
C 
C   OUTPUT: 
C 
C       TPIA   - MEASURED TPI LEVEL 
C 
C       SIG    - POPULATION SIGMA 
C 
C       TIMA   - TIME IN SECONDS OF MEASUREMENT RELATIVE TO RUT 
C 
C       IERR = 0 IF NO ERROR OCCURRED 
C 
      double precision tpia1,tpia2,sig1,sig2,timta,timt 
      double precision dri,dim1,didim1,dtpi1,dtpi2
      integer it(5),iti(5)
      integer*4 ip(5)
      integer*2 icmnd(4,18),indata(10),indat2(10)
      integer*2 iques,lwho,lwhat
      logical kbreak, kst1,kst2
C 
      include '../include/fscom.i'
C 
C  WE USE THE FOLLOWING VARIABLES FROM FSCOM
C 
C      LDV1NF, LDV2NF
C 
      data icmnd/ 2hv1, 2h#0,2h1%,2h__, 
     +            2hv2, 2h#0,2h2%,2h__, 
     +            2hv3, 2h#0,2h3%,2h__, 
     +            2hv4, 2h#0,2h4%,2h__, 
     +            2hv5, 2h#0,2h5%,2h__, 
     +            2hv6, 2h#0,2h6%,2h__,
     +            2hv7, 2h#0,2h7%,2h__,
     +            2hv8, 2h#0,2h8%,2h__,
     +            2hv9, 2h#0,2h9%,2h__,
     +            2hva, 2h#0,2ha%,2h__,
     +            2hvb, 2h#0,2hb%,2h__,
     +            2hvc, 2h#0,2hc%,2h__,
     +            2hvd, 2h#0,2hd%,2h__,
     +            2hve, 2h#0,2he%,2h__,
     +            2hvf, 2h#0,2hf%,2h__,
     +            2hi1, 2h#9,2h3!,2h__,
     +            2hi2, 2h#9,2h3!,2h__,
     +            2hi3, 2h#9,2h5%,2h__/
      data iques/2H??/,ndev/18/,lwho/2Hnf/,lwhat/2Hvo/,ntry/1/
      data nin/10/
C
C  0. INITIALIZE
C
C       WHICH DEVICE? 
C 
      kst1=ichcm_ch(ldv1nf,1,'u').eq.0
      if(kst1) then
         id1=-1
         goto 11
      endif
C
      call fs_get_rack(rack) 
      if(VLBA.eq.rack.or.VLBA4.eq.rack) then
        id1=-1
        goto 11
      endif
      do 8 i=1,ndev 
        if (icmnd(1,i).ne.ldv1nf) goto 8 
        id1=i
        goto 11 
8     continue
C 
C            DEVICE NOT FOUND 
C 
      goto 80000 
C 
C            GOT IT 
C 
11    continue
C 
      kst2=ichcm_ch(ldv2nf,1,'u').eq.0
      if(kst2) then
         id2=-1
         goto 13
      endif
C
      call fs_get_rack(rack) 
      if(VLBA.eq.rack.or.VLBA4.eq.rack) then
        id2=-1
        goto 13
      endif
      do 12 i=1,ndev
        if(icmnd(1,i).ne.ldv2nf) goto 12
        id2=i
        goto 13 
12    continue 
C 
C            DEVICE NOT FOUND 
C 
      goto 80000 
C 
C            GOT IT 
C 
13    continue
C 
C       SET UP OTHER THINGS 
C 
      tpia1=0 
      tpia2=0 
      sig1=0
      sig2=0
      timta=0 
C 
C  WAIT ONE SECOND TO CYCLE THE INTEGERATOR 
C   (WE WILL WAIT ON MORE SECOND AT THE BEFORE THE FIRST SAMPLE AS WELL)
C
      if((.not.kst1).or.(.not.kst2)) then
         call susp(1,102)
      endif
      call fc_rte_time(iti,idum) 
C 
C   1. LOOP GETTING DATA
C 
      do 20 i=1,intp
C 
C       WAIT TILL THE NEXT SECOND AT LEAST
C 
        if(kbreak('onoff'))goto 80040
        if((.not.kst1).or.(.not.kst2)) then
           call fc_rte_time(it,idum) 
           itv1=it(1)-iti(1)                    
           itv2=it(2)-iti(2)                    
           itim=itv1*100+itv2+102 
           if (itim.lt.0) itim=itim+6000.            
           call susp(1,itim)
        endif
C 
C      GET THE STUFF
C 
        itry=ntry
15      continue
        if(kst1.or.kst2) then
           if(kst1) then
              idum=ichmv(user_dev1_name,1,ldv1nf,1,2)
           else
              idum=ichmv_ch(user_dev1_name,1,'  ')
           endif
           call fs_set_user_dev1_name(user_dev1_name)
           if(kst2) then
              idum=ichmv(user_dev2_name,1,ldv2nf,1,2)
           else
              idum=ichmv_ch(user_dev1_name,1,'  ')
           endif
           call fs_set_user_dev2_name(user_dev2_name)
           call run_prog('antcn','wait',8,idum,idum,idum,idum)
           call rmpar(ip)
           if(ip(3).ne.0) then
              ierr=-83
              return
           else
              if(kst1) then
                 call fs_get_user_dev1_value(user_dev1_value)
                 dtpi1=user_dev1_value
              endif
              if(kst2) then
                 call fs_get_user_dev2_value(user_dev2_value)
                 dtpi2=user_dev2_value
              endif
           endif
        endif   
        if(VLBA.eq.rack.or.VLBA4.eq.rack) then
           if((.not.kst1).or.(.not.kst2)) then
              call mcbcn2(dtpi1,dtpi2,ierr)
           endif
        else if(rack.eq.MK3.or.rack.eq.MK4) then
           if(.not.kst1) then
              call matcn(icmnd(2,id1),-5,iques,indata,nin, 9,ierr) 
           endif
          if ((kst1.and..not.kst2).or..not.
     +      (id1.gt.15.and.id2.gt.15.and.id1.lt.18.and.id2.lt.18)
     +    ) call matcn(icmnd(2,id2),-5,iques,indat2,nin, 9,ierr) 
        endif
        call fc_rte_time(iti,idum)  
        if (ierr.ne.0) return 
C 
C      CONVERT TO COUNTS
C 
        if(VLBA.ne.rack.and.VLBA4.ne.rack) then
           if(.not.kst1) then
              if (id1.ge.17) dtpi1=float(ia22h(indata(2)))*256.0+ 
     +             float(ia22h(indata(3)))
              if (id1.lt.17) dtpi1=float(ia22h(indata(4)))*256.0+ 
     +             float(ia22h(indata(5)))
          endif
          if ((kst1.and..not.kst2).or..not.
     +      (id1.gt.15.and.id2.gt.15.and.id1.lt.18.and.id2.lt.18)
     +                    ) idum=ichmv(indata,1,indat2,1,10) 
          if(.not.kst2) then
             if (id2.ge.17) dtpi2=float(ia22h(indata(2)))*256.0+ 
     +            float(ia22h(indata(3)))
             if (id2.lt.17) dtpi2=float(ia22h(indata(4)))*256.0+ 
     +            float(ia22h(indata(5)))
          endif
       endif
C 
C       CHECK FOR TPI SATURATION
C 
        if (dtpi1.lt.65534.5d0.and.dtpi2.lt.65534.5d0) goto 16 
        call logit7(idum,idum,idum,-1,-80,lwho,lwhat) 
        itry=itry-1
        if (itry.le.0) goto 80010
        goto 15 
C 
C       CALCULATE TIME
C 
16      continue 
        dim1=dble(float(i-1))
        dri=1.0d0/dble(float(i)) 
        tpia1=(tpia1*dim1+dtpi1)*dri 
        tpia2=(tpia2*dim1+dtpi2)*dri 
        sig1=(sig1*dim1+dtpi1*dtpi1)*dri 
        sig2=(sig2*dim1+dtpi2*dtpi2)*dri 
        timt=float(iti(2))+float(iti(3))*60.0+ 
     +       float(iti(4))*3600.0  
        if (timt.lt.dble(rut)) timt=timt+86400.0d0
        timta=(timta*dim1+timt)*dri
20    continue 
C 
C        AVERAGE TIME AND COUNTS
C 
      if(intp.gt.1) goto 30
      sig1=0
      sig2=0
      goto 35
C 
30    continue
      didim1=dble(float(intp))/dble(float(intp-1))
      sig1=dsqrt(dabs(sig1-tpia1*tpia1)*didim1) 
      sig2=dsqrt(dabs(sig2-tpia2*tpia2)*didim1) 
C 
35    continue
      tpia(1)=tpia1 
      tpia(2)=tpia2 
      sig(1)=sig1 
      sig(2)=sig2 
      tima=timta
      goto 90000 
C 
C        UNKNOWN DEVICE ERROR 
C 
80000 continue
      ierr=-81
      goto 90000 
C 
C        SATURATION ERRORS
C 
80010 continue
      ierr=-82
      goto 90000 
C 
C  BREAK DETECTED 
C 
80040 continue
      ierr=-1 
      goto 90000 
C 
C        CLEAN UP AND EXIT
C 
90000 continue

      return
      end 
