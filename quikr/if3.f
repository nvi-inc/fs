      subroutine if3(ip)
C  IF DISTRIBUTOR #3 CONTROL    <910324.0011>
C 
      dimension ip(5) 
C     INPUT VARIABLES:
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C   COMMON BLOCKS USED
      include '../include/fscom.i'
C
C     CALLED SUBROUTINES: GTPRM2
C
C   LOCAL VARIABLES
C        NCHAR  - number of characters in buffer
C        ICH    - character counter
      integer*2 IBUF(20)                      ! Class buffer
      integer get_buf,ichcm_ch
      character cjchar
      logical kdef,kfirst,kmaxold
      integer isw(4)                          ! switch settings
      dimension iparm(2)                      ! parameters from gtprm
      dimension ireg(2)                       ! registers from exec calls
      equivalence (reg,ireg(1)),(parm,iparm(1))
C
C  LOCAL CONSTANT
      parameter (ilen=40)
C
C  PROGRAMMER: NRV
C     LAST MODIFIED: 810207
C
C 
C     1. If we have a class buffer, then we are to set the IFD. 
C     If no class buffer, we have been requested to read the IFD. 
C 
      kfirst=.true.
      kdef=.false.
      ichold = -99
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1
        goto 990
      endif
      call ifill_ch(ibuf,1,ilen,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500                ! if no parameters, read device
      if (cjchar(ibuf,ieq+1).eq.'?') then
        ip(1) = 0
        ip(4) = o'77'
        call if3dis(ip,iclcm,kfirst)
        return
      endif
C 
      if (ichcm(ibuf,ieq+1,ltsrs,1,ilents).eq.0) goto 600
      if (ichcm(ibuf,ieq+1,lalrm,1,ilenal).eq.0) goto 700 
C 
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C                   IF3=<atten>,<mixer>,<sw1>,<sw2>,<sw3>,<sw4>,<pcal>
C     Choices are:<atten>: attenuator setting, 0 to 63db. Default 0.
C                          If number is signed, interpret as a change to
C                          the present attenuator setting.
C                          IF atten is MAX, go to 63 and remember old value.
C                          IF atten is OLD, return to old value.
C                 <mixer>: IN or OUT, default OUT
C                 <swX>:   output port X, 1 or 2, default 1
C                 <pcal>:  pcal control (if available), ON or OFF, default ON
C
C     2.1 ATTEN PARAMETER 1
C
      kmaxold=.false.
      ich = 1+ieq
      ist = ich
      call gtprm2(ibuf,ich,nchar,0,parm,ierr)
      if(ichcm_ch(iparm,1,'max').eq.0) then
         kmaxold=.true.
        call fs_get_iat3if(iat3if)
        iold=iat3if
        iat=63
      else if(ichcm_ch(iparm,1,'old').eq.0) then
         kmaxold=.true.
        iat=iolif3_fs
      else
        ich=ist
        call gtprm2(ibuf,ich,nchar,1,parm,ierr)
        if (ierr.eq.2) then
          kdef=.true.
          iat = 0              ! default
        else if (ierr.eq.1) then
          call fs_get_iat3if(iat3if)
          iat = iat3if
        else if (iparm(1).lt.0.or.iscn_ch(ibuf,ist,ich-1,'+').ne.0) then
          call fs_get_iat3if(iat3if)
          iat = iat3if + iparm(1)
        else
          iat = iparm(1)
        endif
      endif
      if (iat.lt.0.or.iat.gt.63) then
        ierr = -201
        goto 990
      endif
      call fs_get_if3_set(if3_set)
      if3_set_save=if3_set
      if(kdef.and.if3_set.ne.1) then
         call get_at3(iat3,ip)
         if(ip(3).lt.0) then
            ierr=-300
            goto 990
         endif
         iat=iat3
      else if(kdef) then
         call fs_get_iat3if(iat3if)
         iat = iat3if
      endif
C
C     2.2 mixer - PARAMETERS 2
C 
      ic1 = ich 
      call gtprm2(ibuf,ich,nchar,0,parm,ierr) 
      if (ierr.eq.2) then
        imix = 2             !default out
      else if (ierr.eq.1) then
         call fs_get_imixif3(imixif3)
        imix = imixif3
      else
        call iif3ed(1,imix,ibuf,ic1,ich-2)
        if (imix.lt.0) then
          ierr = -202
          goto 990
        endif
      endif
C
C     2.3 sw1-sw4, parameters 3-6
C
      call fs_get_iswif3_fs(iswif3_fs)
      do i=1,4
        call gtprm2(ibuf,ich,nchar,1,parm,ierr)
        if(ierr.eq.2) then
          isw(i)=1
        else if (ierr.eq.1) then
          isw(i) = iswif3_fs(i)
          if(isw(i).gt.2.or.isw(i).lt.1) isw(i)=1
        else
          if(iparm(1).lt.1.or.iparm(1).gt.2) then
            ierr = -202 - i
            goto 990
          endif
          isw(i)=iparm(1)
        endif
      enddo
C
C   2.4 pcal control On or OFF, parameter 7
C
      call fs_get_ipcalif3(ipcalif3)
      ic1 = ich 
      call gtprm2(ibuf,ich,nchar,0,parm,ierr) 
      if (ierr.eq.2) then
        ipcal = 1             !default on
      else if (ierr.eq.1) then
        ipcal = ipcalif3
      else
        call iif3ed(2,ipcal,ibuf,ic1,ich-2)
        if (ipcal.lt.0) then
          ierr = -207
          goto 990
        endif
      endif
C
C     3. Finally, format the buffer for the controller.
C     We have a valid IAT(1),IAT(2),INP(1),INP(2).
C
      ibuf(1) = 0
      call char2hol('i3',ibuf(2),1,2)
      call i32ma(ibuf(3),iat,imix,isw(1),isw(2),isw(3),isw(4),ipcal)
C
C     4. Now plant these values into COMMON.
C     Next send the buffer to SAM.
C     Finally schedule BOSS to request that MATCN gets the data.
C
      call fs_get_icheck(icheck(23),23)
      ichold = icheck(23)
      icheck(23)=0
      call fs_set_icheck(icheck(23),23)
      iat3if = iat
      call fs_set_iat3if(iat3if)
      imixif3 = imix
      call fs_set_imixif3(imixif3)
      do i=1,4
        iswif3_fs(i)=isw(i)
      enddo
      call fs_set_iswif3_fs(iswif3_fs)
      ipcalif3=ipcal
      call fs_set_ipcalif3(ipcalif3)
      iolif3_fs = iold
      if3_set=1
      call fs_set_if3_set(if3_set)
C
      iclass=0
      nch = 12
      call put_buf(iclass,ibuf,-nch,'fs','  ')
C
      nrec = 1
      goto 800
C 
C 
C     5.  This is the read device section.
C     Fill up two class buffers, one requesting % data (mode -2), 
C     the other ! (mode -1).
C 
500   call char2hol('i3',ibuf(2),1,2)
      iclass = 0
      do i=1,2
        ibuf(1) = -i
        call put_buf(iclass,ibuf,-4,'fs','  ')
      enddo
C 
      nrec = 2
      goto 800
C 
C 
C 
C     6. This is the test/reset device section. 
C 
600   ibuf(1) = 6 
      call char2hol('i3',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      nrec = 1
      goto 800
C 
C 
C     7. This is the alarm query and reset request. 
C 
700   ibuf(1) = 7 
      call char2hol('i3',ibuf(2),1,2)
      iclass=0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      nrec = 1
      goto 800
C
C
C     8. All MATCN requests are scheduled here, and then IFDIS called.
C
800   call run_matcn(iclass,nrec)
      call rmpar(ip)
       if (ichold.ne.-99) then
        icheck(23) = ichold
        call fs_set_icheck(icheck(23),23)
      endif
      if (ichold.gt.0.or.(ichold.eq.0.and..not.kmaxold)) then
        icheck(23)=mod(ichold,1000)+1
        call fs_set_icheck(icheck(23),23)
      endif
      call if3dis(ip,iclcm,kfirst)
      if(kfirst.and.ieq.ne.0.and.kdef) then
         kfirst=.false.
         if(ip(1).ne.0) call clrcl(ip(1))
         if(if3_set_save.ne.1) then
            call logit7ci(0,0,0,0,-301,'q+',0)
         else
            call logit7ci(0,0,0,0,-302,'q+',0)
         endif
         goto 500
      endif
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('q+',ip(4),1,2)
      return
      end
