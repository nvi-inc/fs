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
      logical kst
      data icmnd/ 2H#9,2H3%,2H__/,iques/2H??/,idolr/2H$$/
      data isav/2h#9,2H3=,0,0,0,0,2H__,0,0,0/
      data izero/2H#9,2H3=,2H00,2H00,2H3f,2H3f,2H__,0,0,0/
      data nin/-20/,lwho/2hfp/,name/'fivpt'/
C
      kst=ichcm_ch(ldevfp,1,'u').eq.0
C
C MAKE SURE THE CAL IS OFF
C
      call fs_get_rack(rack)
      call fs_get_dbbc_cont_cal_mode(dbbc_cont_cal_mode)
      if(calfp.gt.0.0.and.
     &     ((rack.ne.DBBC.and.rack.ne.RDBE).or.
     &     (rack.eq.DBBC.and.dbbc_cont_cal_mode.eq.0))) then
c     &     (rack.eq.RDBE.and.dbbc_cont_cal_mode.eq.0))) then
         call scmds('calofffp',1)
      endif
C
C  READ EXISTING IFD ATTENUATOR SETTINGS
C
      call fs_get_rack(rack)
      if(.not.kst) then
         if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
            if(ichfp_fs.ne.3) then
               call matcn(icmnd,-5,iques,indata,nin, 9,ierr)
               if (ierr.ne.0) return
c     write(6,9954) nin,(indata(iweh),iweh=1,6)
c9954 format(' nin',i10,' indata "',6a2,'"')
               call char2hol('93',isav,2,3)
               idum=ichmv(isav,5,indata,3,8)
            else
               call char2hol('95',isav,2,3)
               call fs_get_imixif3(imixif3)
               call fs_get_iat3if(iat3if)
               call fs_get_iswif3_fs(iswif3_fs)
               call fs_get_ipcalif3(ipcalif3)
               call i32ma(isav(3),iat3if,imixif3,iswif3_fs(1),
     &              iswif3_fs(2),iswif3_fs(3),iswif3_fs(4),ipcalif3)
            endif
         else if(VLBA.eq.rack.or.VLBA4.eq.rack) then
            call get_vatt(name,lwho,ierr,ichfp_fs,0)
            if (ierr.ne.0) return
         else if(LBA.eq.rack.or.DBBC.eq.rack.or.RDBE.eq.rack) then
c           digital detector - assume tpzero=0
         endif
      endif
C
C  TURN ON ALL THE ATTENUATORS
C
      if (kst) then
         call scmds('sigofffp',1)
         ierr=0
      else if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
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
            call fs_get_imixif3(imixif3)
            call fs_get_iswif3_fs(iswif3_fs)
            call fs_get_ipcalif3(ipcalif3)
            call i32ma(izero(3),63,imixif3,iswif3_fs(1),
     &           iswif3_fs(2),iswif3_fs(3),iswif3_fs(4),ipcalif3)
         endif
         call matcn(izero,-13,idolr,indata,nin,2,ierr)
      else if(VLBA.eq.rack.or.VLBA4.eq.rack) then
        call zero_vatt(name,lwho,ierr)
      else if(LBA.eq.rack.or.DBBC.eq.rack.or.RDBE.eq.rack) then
c       digital detector - assume tpzero=0
      endif
      if (ierr.ne.0) goto 8000
C
C  OKAY GET THE VOLTS
C
      if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack.or.
     .   VLBA.eq.rack.or.VLBA4.eq.rack) then
        call volts(0,vbase,sig,vdum,sigdum,tdum,intp,rut,ierr,icont)
      else if(LBA.eq.rack.or.rack.eq.DBBC.or.rack.eq.RDBE) then
c       digital detector - assume tpzero=0
	vbase=0.0
	sig=0.0
	tdum=0
	ierr=0
      endif
      if (ierr.ne.0) goto 8000
C
C  RESET THE ATTENUATORS
C
      if (kst) then
         call scmds('sigonfp',1)
         ierr=0
      else if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
         call matcn(isav,-13,idolr,indata,nin,2,ierr)
      else if(VLBA.eq.rack.or.VLBA4.eq.rack) then
         call rst_vatt(name,lwho,ierr)
      else if(LBA.eq.rack.or.DBBC.eq.rack.or.RDBE.eq.rack) then
c        digital detector - assume tpzero=0
      endif
      if (ierr.ne.0) goto 8000
C
C  NOW SET GET THE TPI READING
C
      call volts(1,tpia,sigts,tpical,sig,tima,intp,rut,ierr,icont)
      if (ierr.ne.0) goto 8000
C
C  NOW DO TPICAL
C
c      write(6,*) 'icont',icont
      call fs_get_rack(rack)
      call fs_get_dbbc_cont_cal_mode(dbbc_cont_cal_mode)
      if(calfp.gt.0.0.and.
     &     ((rack.ne.DBBC.and.rack.ne.RDBE).or.
     &     (rack.eq.DBBC.and.dbbc_cont_cal_mode.eq.0))) then
c     &     (rack.eq.RDBE.and.dbbc_cont_cal_mode.eq.0))) then
C
C       TURN CAL ON
C 
            call scmds('calonfp',1)
C 
C       GET DATA
C
            call volts(0,
     &           tpical,sig,tpidum,sigdum,tdum,intp,rut,ierr,icont) 
C 
C       CAL OFF
C
            call scmds('calofffp',1)
C
C error handling got volts call above to make sure calofffp gets executed
C
            if (ierr.ne.0) goto 8000

C
C  FINALLY, GET THE SYSTEM TEMPEARTURE AND VSLOPE
C
         vslope=calfp/(tpical-tpia)
         temps=(tpia-vbase)*vslope
      else if(rack.eq.RDBE .or.
     &        (rack.eq.DBBC.and.dbbc_cont_cal_mode.eq.1)) then
         if(calfp.gt.0) then
            vslope=calfp/(tpical-tpia)
            temps=(tpia-vbase)*vslope
         else
            tpia=(tpia+tpical)/2
            temps=-calfp
            vslope=temps/(tpia-vbase)
         endif
      else
         temps=-calfp
         vslope=temps/(tpia-vbase)
      endif
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
      if (kst) then
         call scmds('sigonfp',1)
         jerr=0
      else if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
         call matcn(isav,-13,idolr,indata,nin,2,jerr)
      else if(VLBA.eq.rack.or.VLBA4.eq.rack) then
         call rst_vatt(name,lwho,jerr)
      else if(LBA.eq.rack.or.DBBC.eq.rack.or.rack.eq.RDBE) then
c       digital detector - assume tpzero=0
      endif
      jtry=jtry-1
      if (jerr.gt.0.and.jtry.gt.0) goto 8001
      if (jerr.ne.0) call logit7ic(idum,idum,idum,-1,-110,lwho,'er')

      return
      end 
