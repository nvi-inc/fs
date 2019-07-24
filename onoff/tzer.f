      subroutine tzer(vzero,sigzer,timzer,intp,rut,ierr)
      dimension vzero(2),sigzer(2)
C 
C  GET TPZERO 
C 
C  INPUT: 
C 
C        INTP = INTEGRATION PERIOD IN SECONDS 
C 
C        RUT  = REFERENCE UT TIME OF DAY IN SECONDS 
C 
C  OUTPUT:
C 
C        VZERO = VOLTAGE OF ZERO READING
C 
C        SIGZER= SIGMA OF ZERO IF MORE THAN 1 INTEGRATION 
C 
C        TIMZER= SECONDS SINCE RUT
C 
C        IERR = O IF NO ERROR OCCURRED
C 
      include '../include/fscom.i'
C 
C  WE READ THE FOLLOWING VALUES FROM FSCOM
C 
C
      integer*2 icmnd(3),iques,idolr,isav(10),izero(10),indata(10)
      integer*2 lwho
      character*5 name

      data icmnd/ 2H#9,2H3%,2H__/,iques/2H??  /,idolr/2H$$  /
      data isav/2H#9,2H3=,0,0,0,0,2H__,0,0,0/
      data izero/2H#9,2H3=,2H00,2H00,2H3f,2H3f,2H__,0,0,0/
      data nin/-20/,lwho/2hnf/,name/'onoff'/
C
C  READ EXISTING IFD ATTENUATOR SETTINGS
C
      call fs_get_rack(rack)
      if(VLBA.eq.iand(rack,VLBA)) then
        call get_vatt(name,lwho,ierr)
        if(ierr.ne.0) return
      else
        call matcn(icmnd,-5,iques,indata,nin, 9,ierr)
        if (ierr.ne.0) return
        call ichmv(isav,5,indata,3,8)
      endif
C
C  TURN ON ALL THE ATTENUATORS
C
      if(VLBA.eq.iand(rack,VLBA)) then
        call zero_vatt(name,lwho,ierr)
      else
        call ichmv(izero,5,indata,3,4)
        call matcn(izero,-13,idolr,indata,nin,2,ierr)
      endif
      if (ierr.ne.0) goto 8000
C
C  OKAY GET THE VOLTS
C
      call vlts2(vzero,sigzer,timzer,intp,rut,ierr)
      if (ierr.ne.0) goto 8000
C
C  RESET THE ATTENUATORS
C
      if(VLBA.eq.iand(rack,VLBA)) then
        call rst_vatt(name,lwho,ierr)
      else
        call matcn(isav,-13,idolr,indata,nin,2,ierr)
      endif
      if (ierr.ne.0) goto 8000
C
      return
C
C  ERROR RETURN, RESET ATTENUATORS
C
8000  continue
      jtry=2
C
8001  continue
      jerr=0
      if(VLBA.eq.iand(rack,VLBA)) then
        call rst_vatt(name,lwho,jerr)
      else
        call matcn(isav,-13,idolr,indata,nin,2,jerr)
      endif
      jtry=jtry-1
      if (jerr.gt.0.and.jtry.gt.0) goto 8001
      if (jerr.ne.0) call logit6(idum,idum,idum,-1,-110,lwho)
c
      return
      end
