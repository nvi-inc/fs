      subroutine volts(imode,
     &     tpia,sig,tpia2,sig2,tima,intp,rut,ierr,icont) 
C 
C   TOTAL POWER INTEGERATION ROUTINE, THIS ROUTINE READS THE TPI
C       FOR THE SPECIFIED DEVICE
C 
C   INPUT:
C 
C       IMODE  - 0= return both non-continuous and continous samples in tpia
C                0!= if continuous return tpical values in tpia2
C                    if not continuous: just return tpia
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
C       ICONT == 0 if not continuous cal
C             != 0 if continups cal
C
      double precision timt,dtpi,dri,tpita,sigt,timta,didim1
      double precision dtpi2,tpita2,sigt2
      integer*2 icmnd(4,18),indata(10),iques,lwho,lwhat
      integer it(5),iti(5)
      integer*4 ip(5)
c     character*1 cjchar
      logical kbreak, kst
C 
       include '../include/fscom.i'
C 
C  WE USE THE FOLLOWING VARIABLES FROM FSCOM
C 
C      LDEVFP, LUMAT
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
      data iques/2H??/,ndev/18/,lwho/2Hfp/,lwhat/2Hvo/,ntry/1/
      data nin/10/
C
C  0. INITIALIZE
C
C       WHICH DEVICE?
C 
      kst=ichcm_ch(ldevfp,1,'u').eq.0
      if(kst) then
         id=-1
         goto 11
      endif
C
      call fs_get_rack(rack)
      call fs_get_rack_type(rack_type)
      if(VLBA.eq.rack.or.VLBA4.eq.rack) then
        id=-1
        goto 11
      else if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
c       do nothing
      else if(LBA.eq.rack) then
        id=-1
        goto 11
      else if(DBBC.eq.rack.and.
     &       (rack_type.eq.DBBC_DDC.or.rack_type.eq.DBBC_DDC_FILA10G)
     &       )then
        id=-1
        goto 11
      endif
c
c  check M3 devices
c
      do 8 i=1,ndev 
        if (icmnd(1,i).ne.ldevfp) goto 8 
        id=i 
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
C       SET UP OTHER THINGS 
C 
      tpia=0
      sig=0 
      tima=0
      tpia2=0
      sig2=0
C 
C       WAIT FOR A SECOND TO CYCLE TPI
C        (WE WILL WAIT AN ADDITIONAL SECOND BEFORE THE FIRST READING) 
C 
      if(.not.kst) then
         call susp(1,102)
         call fc_rte_time(iti,idum) 
      endif
C 
C   1. LOOP GETTING DATA
C 
      icont=0
C
      i=0
10000 continue
      i=i+1
      if(i.gt.intp) goto 20000
        dtpi2=0.0d0
C 
C       WAIT TILL THE NEXT SECOND AT LEAST
C 
        if (kbreak('fivpt')) goto 80040  
        if(.not.kst) then
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
12      continue 
        if(kst) then
           idum=ichmv(user_dev1_name,1,ldevfp,1,2)
           call fs_set_user_dev1_name(user_dev1_name)
           idum=ichmv_ch(user_dev2_name,1,'  ')
           call fs_set_user_dev2_name(user_dev2_name)
           call run_prog('antcn','wait',8,idum,idum,idum,idum)
           call rmpar(ip)
           if(ip(3).ne.0) then
              ierr=-83
           else
              call fs_get_user_dev1_value(user_dev1_value)
              dtpi=user_dev1_value
           endif
        else if(VLBA.eq.rack.or.VLBA4.eq.rack) then
           call mcbcn(dtpi,ierr)
        else if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
           call matcn(icmnd(2,id),-5,iques,indata,nin, 9,ierr)
        else if(LBA.eq.rack) then
           call dscon(dtpi,ierr)
        else if(DBBC.eq.rack.and.
     &          (rack_type.eq.DBBC_DDC.or.rack_type.eq.DBBC_DDC_FILA10G)
     &          ) then
           call dbbcn(dtpi,dtpi2,ierr,icont,isamples)
           if(imode.ne.0.and.i.eq.1.and.icont.ne.0) then
              if(isamples.gt.intp) then
                 intp=isamples
              endif
           endif
        endif
        call fc_rte_time(iti,idum)
        if (ierr.ne.0) return 
C 
C      CONVERT TO COUNTS
C 
        if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
          if (id.ge.17) dtpi=float(ia22h(indata(2)))*256.0+ 
     +                       float(ia22h(indata(3)))
          if (id.lt.17) dtpi=float(ia22h(indata(4)))*256.0+ 
     +                       float(ia22h(indata(5)))
c         write(6,9953) dtpi,(cjchar(indata,i),i=1,12)
9953      format(' dtpti ',f20.10,' indata ',12a1)
        endif
C 
C       CHECK FOR TPI SATURATION
C 
        if (dtpi.lt.65534.5d0) goto 16 
        call logit7(idum,idum,idum,-1,-80,lwho,lwhat) 
        itry=itry-1
        if (itry.le.0) goto 80010
        goto 12 
c
 16     continue
        if (icont.eq.0.or.dtpi2.lt.65534.5d0) goto 161 
        call logit7(idum,idum,idum,-1,-80,lwho,lwhat) 
        itry=itry-1
        if (itry.le.0) goto 80010
        goto 12 
C 
C       CALCULATE TIME
C 
 161    continue 
        if(icont.eq.0) then
           dim1=dble(float(i-1))
           dri=1.0d0/dble(float(i)) 
           tpita=(tpita*dim1+dtpi)*dri  
           sigt=(sigt*dim1+dtpi*dtpi)*dri 
        else if(imode.eq.0) then
           dim1=dble(float(2*(i-1)))
           dri=1.0d0/dble(float(2*i)) 
           tpita=(tpita*dim1+dtpi+dtpi2)*dri  
           sigt=(sigt*dim1+dtpi*dtpi+dtpi2*dtpi2)*dri 
        else
           dim1=dble(float(i-1))
           dri=1.0d0/dble(float(i)) 
           tpita=(tpita*dim1+dtpi)*dri  
           sigt=(sigt*dim1+dtpi*dtpi)*dri 
           tpita2=(tpita2*dim1+dtpi2)*dri  
           sigt2=(sigt2*dim1+dtpi2*dtpi2)*dri 
        endif
        timt=float(iti(2))+float(iti(3))*60.0+ 
     +       float(iti(4))*3600.0  
        if (timt.lt.dble(rut)) timt=timt+86400.0d0
        timta=(timta*dim1+timt)*dri
      goto 10000
20000 continue
C 
C        AVERAGE TIME AND COUNTS
C 
      if (intp.gt.1) goto 30
      sigt=0
      if(icont.ne.0.and.imode.ne.0)then
         sigt2=0
      endif
      goto 35
C 
30    continue
      if(icont.eq.0) then
         didim1=dble(float(intp))/dble(float(intp-1))
         sigt=dsqrt(dabs(sigt-tpita*tpita)*didim1) 
      else if(imode.eq.0) then
         didim1=dble(float(2*intp))/dble(float(2*(intp-1)))
         sigt=dsqrt(dabs(sigt-tpita*tpita)*didim1) 
      else
         didim1=dble(float(intp))/dble(float(intp-1))
         sigt=dsqrt(dabs(sigt-tpita*tpita)*didim1) 
         sigt2=dsqrt(dabs(sigt2-tpita2*tpita2)*didim1) 
      endif
C 
35    continue
      tpia=tpita
      sig=sigt
      if(icont.ne.0.and.imode.ne.0)then
         tpia2=tpita2
         sig2=sigt2
      endif
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
      ierr=1
      goto 90000 
C 
C        CLEAN UP AND EXIT
C 
90000 continue

      return
      end 
