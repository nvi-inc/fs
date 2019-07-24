      subroutine tsys(temps,sigts,tpia,tima,vbase,vslope,intp,rut,ierr)
C 
C  GET SYSTEM TEMPERATURE AND BASELINE TPI READING
C 
C  INPUT: 
C 
C        INTP = INTEGRATION PERIOD IN SECONDS 
C 
C        RUT  = REFERENCE UT TIME OF DAY IN SECONDS 
C 
C  OUTPUT:
C 
C        TEMPS = CALCULATED SYSTEM TEMPERATURE
C 
C        TPIA  = OBSERVED TPI READING 
C 
C        TIMA  = SECONDS SINCE RUT
C 
C        VBASE = TPIZERO READING
C 
C        VLSOPE = FACTOR FOR CONVERSION OF COUNTS TO DEGREES
C
C        IERR = O IF NO ERROR OCCURRED
C
       include '../include/fscom.i'
C
C  WE READ THE FOLLOWING VALUES FROM FSCOM
C
C      CALFP
C
      integer*2 icmnd(3),iques,idolr,indata(12),isav(10),izero(10)
      integer*2 lwho
      character*5 name
      data icmnd/ 2H#9,2H3%,2H__/,iques/2H??/,idolr/2H$$/
      data isav/2h#9,2H3=,0,0,0,0,2H__,0,0,0/
      data izero/2H#9,2H3=,2H00,2H00,2H3f,2H3f,2H__,0,0,0/
      data nin/-20/,lwho/2hfp/,name/'fivpt'/
C
C MAKE SURE THE CAL IS OFF
C
      call scmds(8Hcalofffp,8)
C
C  READ EXISTING IFD ATTENUATOR SETTINGS
C
      call fs_get_rack(rack)
      if(VLBA.ne.iand(rack,VLBA)) then
        if(ichfp_fs.ne.3) then
          call matcn(icmnd,-5,iques,indata,nin, 9,ierr)
          if (ierr.ne.0) return
c         write(6,9954) nin,(indata(iweh),iweh=1,6)
c9954      format(' nin',i10,' indata "',6a2,'"')
          call char2hol('93',isav,2,3)
          idum=ichmv(isav,5,indata,3,8)
        else
          call char2hol('95',isav,2,3)
          call i32ma(isav(3),iatif3_fs,imixif3_fs,iswif3_fs(1),
     &               iswif3_fs(2),iswif3_fs(3),iswif3_fs(4))
        endif
      else
        call get_vatt(name,lwho,ierr,ichfp_fs,0)
        if (ierr.ne.0) return
      endif
C
C  TURN ON ALL THE ATTENUATORS
C
      if(VLBA.ne.iand(rack,VLBA)) then
        if(ichfp_fs.ne.3) then
          idum=ichmv(izero,5,indata,3,10)
          call char2hol('93',izero,2,3)
          if(ichfp_fs.eq.1) then
            call char2hol('3f',izero,11,12)
          else
            call char2hol('3f',izero,9,10)
          endif
        else
          call char2hol('95',izero,2,3)
          call i32ma(izero(3),63,imixif3_fs,iswif3_fs(1),
     &               iswif3_fs(2),iswif3_fs(3),iswif3_fs(4))
        endif
        call matcn(izero,-13,idolr,indata,nin,2,ierr)
      else
        call zero_vatt(name,lwho,ierr)
      endif
      if (ierr.ne.0) goto 8000
C
C  OKAY GET THE VOLTS
C
      call volts(vbase,sig,tdum,intp,rut,ierr)
      if (ierr.ne.0) goto 8000
C
C  RESET THE ATTENUATORS
C
      if(VLBA.ne.iand(rack,VLBA)) then
         call matcn(isav,-13,idolr,indata,nin,2,ierr)
      else
         call rst_vatt(name,lwho,ierr)
      endif
      if (ierr.ne.0) goto 8000
C
C  NOW SET GET THE TPI READING
C
      call volts(tpia,sigts,tima,intp,rut,ierr)
      if (ierr.ne.0) goto 8000
C
C  NOW DO TPICAL
C
C       TURN CAL ON
C 
      call scmds(8Hcalonfp ,7)  
C 
C       GET DATA
C 
      call volts(tpical,sig,tdum,intp,rut,ierr) 
      if (ierr.ne.0) goto 8000
C 
C       CAL OFF
C
      call scmds(8Hcalofffp,8)
C
C  FINALLY, GET THE SYSTEM TEMPEARTURE AND VSLOPE
C
      vslope=calfp/(tpical-tpia)
      temps=(tpia-vbase)*vslope
      sigts=sigts*vslope
      return
C
C  ERROR RETURN, RESET ATTENUATORS
C
8000  continue
      jtry=2
C
8001  continue
      jerr=0
      if(VLBA.ne.iand(rack,VLBA)) then
         call matcn(isav,-13,idolr,indata,nin,2,jerr)
      else
         call rst_vatt(name,lwho,jerr)
      endif
      jtry=jtry-1
      if (jerr.gt.0.and.jtry.gt.0) goto 8001
      if (jerr.ne.0) call logit7(idum,idum,idum,-1,-110,lwho,2Her)

      return
      end 
