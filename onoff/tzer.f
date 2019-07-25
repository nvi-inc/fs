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
      integer*2 isav3(10),izero3(10)
      integer*2 lwho
      character*5 name
      logical kif1,kif2,kif3

      data icmnd/ 2H#9,2H3%,2H__/,iques/2H??  /,idolr/2H$$  /
      data isav /2H#9,2H3=,0,0,0,0,2H__,0,0,0/
      data isav3/2H#9,2H5=,0,0,0,0,2H__,0,0,0/
      data izero /2H#9,2H3=,2H00,2H00,2H3f,2H3f,2H__,0,0,0/
      data izero3/2H#9,2H5=,2H00,2H00,2H3f,2H3f,2H__,0,0,0/
      data nin/-20/,lwho/2hnf/,name/'onoff'/
C
C  READ EXISTING IFD ATTENUATOR SETTINGS
C
      call fs_get_rack(rack)
      if(VLBA.eq.and(rack,VLBA)) then
        call get_vatt(name,lwho,ierr,ich1nf_fs,ich2nf_fs)
        if(ierr.ne.0) return
      else
        kif1=ich1nf_fs.eq.1.or.ich2nf_fs.eq.1
        kif2=ich1nf_fs.eq.2.or.ich2nf_fs.eq.2
        kif3=ich1nf_fs.eq.3.or.ich2nf_fs.eq.3
        if(kif1.or.kif2) then
          call matcn(icmnd,-5,iques,indata,nin, 9,ierr)
          if (ierr.ne.0) return
          call ichmv(isav,5,indata,3,8)
        endif
        if(kif3) then
          call i32ma(isav3(3),iatif3_fs,imixif3_fs,iswif3_fs(1),
     &               iswif3_fs(2),iswif3_fs(3),iswif3_fs(4))
        endif
      endif
C
C  TURN ON ALL THE ATTENUATORS
C
      if(VLBA.eq.and(rack,VLBA)) then
        call zero_vatt(name,lwho,ierr)
      else
        if(kif1.or.kif2) then
          call ichmv(izero,5,indata,3,10)
          if(kif1) call char2hol('3f',izero,11,12)
          if(kif2) call char2hol('3f',izero,9,10)
          call matcn(izero,-13,idolr,indata,nin,2,ierr)
          if (kif3.and.ierr.ne.0) goto 8000
        endif
        if(kif3) then
          call i32ma(izero3(3),63,imixif3_fs,iswif3_fs(1),
     &               iswif3_fs(2),iswif3_fs(3),iswif3_fs(4))
          call matcn(izero3,-13,idolr,indata,nin,2,ierr)
        endif
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
      if(VLBA.eq.and(rack,VLBA)) then
        call rst_vatt(name,lwho,ierr)
      else
        if(kif1.or.kif2) then
          call matcn(isav,-13,idolr,indata,nin,2,ierr)
          if(kif3.and.ierr.ne.0) goto 8000
        endif
        if(kif3) call matcn(isav3,-13,idolr,indata,nin,2,ierr)
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
      jerr3=0
      if(VLBA.eq.and(rack,VLBA)) then
        call rst_vatt(name,lwho,jerr)
      else
        if(kif1.or.kif2) then
          call matcn(isav,-13,idolr,indata,nin,2,jerr)
        endif
        if(kif3) call matcn(isav3,-13,idolr,indata,nin,2,jerr3)
      endif
      jtry=jtry-1
      if(VLBA.ne.and(rack,VLBA)) then   !don't retry device that was okay
        if((kif1.or.kif2).and.(jerr.eq.0)) then
          kif1=.false.
          kif2=.false.
        endif
        if(kif3.and.jerr3.eq.0) then
          kif3=.false.
        endif
      endif
      if ((jerr.gt.0.or.jerr3.gt.0).and.jtry.gt.0) goto 8001
      if (jerr.ne.0.or.jerr3.ne.0)
     &   call logit6(idum,idum,idum,-1,-110,lwho)
c
      return
      end
