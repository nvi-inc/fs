      program ibcon
C 
C HISTORY::
C   NRV
C   LNF  791129		SET TIMEOUT RETURN TO USER
C   GAG  901220         Added a call to logit on error condition when 
C			initializing MODTBL
C   JFHQ 940124  	Re-fixed Read/Write buffer truncation bugs 
C   DMV  941213		removed nchr2, changed logic of if statements, 
C
C     PROGRAM STRUCTURE
C 1.1.   IBCON controls the I/O to the GP Interface Bus 
C 
C 2.  IBCON INTERFACE 
C 
C 2.1.   CALLING SEQUENCE: IBCON(IP1,IP2,IP3,IP4,IP5)
C 
C     INPUT VARIABLES: (RMPAR)
C 
C        IP1    - class number of input buffer
C                   word1 is mode 
C                   1=ASCII read data, device mnemonic in word 2
C                   2=ASCII write data, device in word 2, data in words 3 - end
C		    3=BINARY read
C		    4=BINARY write 
C        IP2    - number of records in class
C 
C     OUTPUT VARIABLES:   (RMPAR) 
C 
C        IP1    - class number of output buffer 
C        IP2    - number of records in class
C        IP3    - error code
C                  0 - no error 
C                 -1 - trouble with class buffer
C                 -2 - illegal mode
C                 -3 - unrecognized device
C                 -4 - device time-out on response
C                 -5 - improper response (wrong number of chars)
C                 -6 - attempt to read from a listen-only device
C                 -7 - attempt to write to a talk-only device
C                 -8 - device is down
C                 -9 - no data to write
C	 IP4    - 2hex "ib"
C	 IP5    - binary value that will go into error message
C
C 2.2.   COMMON BLOCKS USED
C
      include '../include/fscom.i'
C
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLING SUBROUTINES: BOSS ONLY
C
C     CALLED SUBROUTINES:  SYSTEM CALLS AND ICHMV
C
C 3.  LOCAL VARIABLES
      integer get_buf
C 
      integer*4 ip(5) 
C               - RMPAR 
C        IMODE  - mode for transmission/reception 
C        MAXMOD,MINMOD
C               - maximum, minimum mode numbers allowed 
C        NCHAR  - # chars in class buffer we read 
C        NCH2   - # chars in buffer 2 
C        ICLASS - class # we read 
C        ICLASR - class # we respond with 
C        NCLREC - # class records 
C        ICLREC - counter for outer loop over class records 
C        NADEV  - mnemonic name of device, first word of table
C        IMDEV  - mode of device, from table's third word
C 
      integer ireg,ipcode
      parameter (ibufln= 256)
      integer*2 ibuf(ibufln),ibuf2(ibufln),istatk4(2),irdk4,ilvk4,ilck4
C               - buffers for reading, writing
C        ILEN   - length of above buffers 
      logical kini, kfirst, kgpib
C               - TRUE once we have initialized 
C               - TRUE on the first time through,
C               - TRUE until I know the gpib driver isn't installed
C        NDEV   - # devices in module table 
      parameter (idevln=32)
C        length of device file names, up to 64 characters
      parameter (imaxdev=16)
C        maximum number of devices on IEEE board
      integer iscn_ch, ichmv, icomma, iend, iflch
      integer idlen,it(6)
      integer rddev, opbrd, iserial,opdev, wrdev, idum,statbrd,rspdev
      integer idum,fc_rte_prior, no_after, no_online, no_write_ren
      integer set_remote_enable,no_interface_clear_board
      integer interface_clear_converter
      double precision timnow,timlst(imaxdev)
      integer*4 oldcmd(imaxdev)
      integer*2 moddev(imaxdev,idevln)
C               - module device name
      integer idevid(imaxdev)   
C               - device ids when opened
      integer*2 modtbl(3,imaxdev)  
C               - module table, word 1 = mnemonic, 
C                 word 2 = 0 for talk/listen devices
C                          1 for talk-only devices 
C                          2 for listen-only devices
C                         +4 if SRQ supported
C                 word 3 time-out value
      integer tmotbl(16)
C                        table of time-out values microseconds
C                        =0 disabled
      character*5 name
      integer*4 centisec(2)
      logical kclear
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data kini/.false./,kfirst/.true./,kgpib/.true./
      data minmod/0/, maxmod/12/
      data ilen/512/
      data tmotbl/0,10,30,100,300,1000,3000,10000,  30000,    100000,
     &          300000, 1000000,3000000,10000000,30000000,100000000/
C
C
C     PROGRAM STRUCTURE
C
C     1. First get parameters and initialize if necessary.
C
      call rcpar(0,name)
      call char2hol('STAT',istatk4,1,4)
      call char2hol('LV',ilvk4,1,2)
      call char2hol('RD',irdk4,1,2)
      call char2hol('LC',ilck4,1,2)
c
      call setup_fscom
      call read_fscom
      idum=fc_rte_prior(FS_PRIOR)
      call fc_putpname('ibcon')
c
1     continue
      call wait_prog('ibcon',ip)
      kclear=.true.
      iclass = ip(1)
      nclrec = ip(2)
      iclasr = 0
      nclrer = 0
      ierr = 0
C
C                   Initialize return class and number of records 
C
      if (.not.kfirst) goto 200
      kfirst=.false.
      if (kini) goto 200
C 
C     1.5  Read in device address table.
C     Read table from class buffer
C 
      icount=0
      no_after=0
      no_online=0
      no_write_ren=0
      set_remote_enable=0
      no_interface_clear_board=0
      interface_clear_board=0
      do i=1,nclrec
         ireg = get_buf(iclass,ibuf,-ilen,idum,idum)
         if(ichcm_ch(ibuf,1,'no_untalk/unlisten_after').eq.0) THEN
            no_after=1
            goto 150
         endif
         if(ichcm_ch(ibuf,1,'no_online').eq.0) THEN
            no_online=1
            goto 150
         endif
         if(ichcm_ch(ibuf,1,'no_write_ren').eq.0) THEN
            no_write_ren=1
            goto 150
         endif
         if(ichcm_ch(ibuf,1,'set_remote_enable').eq.0) THEN
            set_remote_enable=1
            goto 150
         endif
         if(ichcm_ch(ibuf,1,'no_interface_clear_board').eq.0) THEN
            no_interface_clear_board=1
            goto 150
         endif
         if(ichcm_ch(ibuf,1,'interface_clear_converter').eq.0) THEN
            interface_clear_converter=1
            goto 150
         endif
         icount=icount+1
         if (icount.gt.imaxdev) then
            call logit7ci(0,0,0,1,-101,'ib',imaxdev)
            call clrcl(iclass)
            goto 151
         endif
         modtbl(1,icount) = ibuf(1)
C !! FIND COMMA AND MOVE DEVICE NAME INTO VARIABLE
C !! IF THERE IS A COMMA, MOVE OPTION INTO VARIABLE 
         icomma = iscn_ch(ibuf,4,ireg,',') 
         if (icomma.eq.0) then
            iend=ireg
            modtbl(2,icount) = 0
         else
            iend = icomma-1
            modtbl(2,icount) = ias2b(ibuf,icomma+1,1)
         endif
         idum = ichmv(moddev(1,icount),1,ibuf,4,iend-3)
         icomma = iscn_ch(ibuf,icomma+1,ireg,',') 
         if (icomma.eq.0) then
            modtbl(3,icount) = 12
         else
            idum = ias2b(ibuf,icomma+1,ireg-icomma)
            do j=1,16
               if(idum.le.tmotbl(j)) then
                  modtbl(3,icount) = j-1
                  goto 148
               endif
            enddo
            modtbl(3,icount) = 15
 148        continue
         endif
 150     continue
      enddo
 151  continue
C
      ndev = min0(icount,imaxdev)
C
      call fs_get_idevgpib(idevgpib)
      if(ichcm_ch(idevgpib,1,'/dev/null ').eq.0) then
         ierr = 0
         goto 1090
      endif
      ingpib = iflch(idevgpib,idevln)
      iserial=opbrd(idevgpib,ingpib,ierr,ipcode,no_online,
     &     set_remote_enable,no_interface_clear_board,
     &     interface_clear_board)            !! OPEN BOARD
      if (ierr.ne.0) goto 1090     		!! GPIB ERROR CONDITION
      call fc_rte_time(it,it(6))
      do i=1,ndev   !! OPEN DEVICES
        idlen = iflch(moddev(1,i),idevln)
        idum=opdev(moddev(1,i),idlen,idevid(i),ierr,ipcode,modtbl(3,i))
        if (ierr.ne.0) goto 1090     		!! GPIB ERROR CONDITION
        timlst(i)=it(1)+it(2)*100.+it(3)*60.d2+it(4)*3600.d2
        oldcmd(i)=-1
      enddo
      kini = .true.
      goto 1090
C
C
C  2. Begin the loop over class buffer records.
C     Read in the buffer, get the mode and module code.
C     Search the module table for a match.
C 
C
200   continue
      if (iclass.eq.0) then
        ierr = -1 
        goto 1090 
      endif
      if(ichcm_ch(idevgpib,1,'/dev/null ').eq.0) then
         ierr = -12
         goto 910
      endif
      if(.not.kini) then
         if(.not.kgpib) then
            ierr=-11
         else
            ierr=-10
         endif
         goto 910
      endif
      do 900 iclrec = 1,nclrec
        ireg = get_buf(iclass,ibuf,-ilen,idum,idum)
c
c to avoid race condition with late clrcl
c
        kclear=iclrec.ne.nclrec
        if(.not.kclear) call clrcl(iclass)
c
        nchar = ireg
	imode = ibuf(1)
        if (imode.lt.minmod.or.imode.gt.maxmod) then
          ierr = -2 
          goto 910
        endif
C  CHECK DEVICE NAME (FIRST WORD)
      do i=1,ndev 
        if (ichcm(modtbl(1,i),1,ibuf(2),1,2).eq.0) then
           idev = i
           nadev = modtbl(1,i)
           imdev = modtbl(2,i)
           goto 221
        endif
      end do
      if(imode.eq.9.or.imode.eq.10.or.imode.eq.12) then
         idev=-1
         call char2hol('  ',nadev,1,2)
         imdev=0
         goto 221
      endif
      ierr = -3 
      goto 910
c
 221  continue
      if((imode.gt.4.and.imode.lt.9).or.imode.eq.11) then
         ilimit=min(ibuf(3),ibufln*2)
      endif
C
      if(idev.gt.0) then
         call fc_rte_time(it,it(6))
         timnow=it(1)+it(2)*100.+it(3)*60.d2+it(4)*3600.d2
         if(timnow.lt.timlst(idev)) then
            timlst(idev)=timlst(idev)-86400.0d2
         endif
      endif
      if (imode.EQ.1 .OR. imode.EQ.3 .or.
     $     imode.eq.5.or.imode.eq.6) then
C
C  3. HERE WE ARE READING DATA FROM A DEVICE.
C
         if (and(imdev,3).NE.0 .AND. and(imdev,3).NE.1) then
            ierr = -6           !! LISTEN-ONLY DEVICE
            goto 910
         endif
         if(imode.eq.1) then
            ibin=0
            if(iserial.ne.0) then
               imax=32
            else
               imax=ibufln*2
            endif
         else if(imode.eq.3) then
            ibin=1
            if(iserial.ne.0) then
               imax=256
            else
               imax=ibufln*2
            endif
         else if(imode.eq.5) then
            ibin=0
            imax=ilimit
         else if(imode.eq.6) then
            ibin=1
            imax=ilimit
         endif
         call fs_get_kecho(kecho)
         ireg = rddev(ibin,idevid(idev),ibuf,imax,ierr,ipcode,300,
     &        no_after,kecho)
         if (ierr .eq. -4) then
            idum=ichmv(ipcode,1,modtbl(1,idev),1,2)
         endif
         if (ierr .LT. 0) goto 910 !! GPIB READ ERROR CONDITION

C     IREG number of characters in the buffer

         if (ireg .GT. ilen) then
            ierr = -321 
            goto 910
         endif

         nclrer = nclrer + 1
         idum = ichmv(ibuf2,3,ibuf,1,ireg)
         ibuf2(1) = nadev       !!MNEMONIC DEVICE NAME 
         call put_buf(iclasr,ibuf2,-ireg-2,'  ','  ')
      else if(imode.eq.2.or.imode.eq.4) then
C
C
C  4. HERE WE ARE WRITING DATA TO THE HPIB.
C
         if (and(imdev,3).NE.0.and.and(imdev,3).ne.2) then
            ierr = -7           !! TALK-ONLY DEVICE
            goto 910
         endif
C
         if (nchar.le.4) then
            ierr = -9           !! NO DATA TO WRITE
            goto 910
         endif
C
         call find_delay(nadev,ibuf(3),nchar-4,oldcmd(idev),timnow,
     &        timlst(idev))
         ibin=0
         if(imode.eq.4) ibin=1
         call fs_get_kecho(kecho)
         idum=wrdev(ibin,idevid(idev),ibuf(3),nchar-4,ierr,ipcode,300,
     &        no_after,kecho,0,centisec,no_write_ren)
         if (ierr .eq. -4) then
            idum=ichmv(ipcode,1,modtbl(1,idev),1,2)
         endif

         if (ierr .LT. 0) goto 910 !! GPIB WRITE ERROR CONDITION
      else if(imode.eq.7.or.imode.eq.8.or.imode.eq.11) then
C
C  5. HERE WE ARE WRITING DATA TO THE HPIB and then reading.
C
         if (and(imdev,3).NE.0) then
            ierr = -13           !! not a TALK/listen DEVICE
            goto 910
         endif
C
         if (nchar.le.6) then
            ierr = -9           !! NO DATA TO WRITE
            goto 910
         endif
C
         call find_delay(nadev,ibuf(4),nchar-6,oldcmd(idev),timnow,
     &        timlst(idev))
         ibin=0
         if(imode.eq.11) then
            itime=1
         else
            itime=0
         endif
         call fs_get_kecho(kecho)
         idum=wrdev(ibin,idevid(idev),ibuf(4),nchar-6,ierr,ipcode,300,
     &        no_after,kecho,itime,centisec,no_write_ren)
         if (ierr .eq. -4) then
            idum=ichmv(ipcode,1,modtbl(1,idev),1,2)
         endif

         if (ierr .LT. 0) goto 910 !! GPIB WRITE ERROR CONDITION
C
C  have to delay for sake of K4 devices
C
         isleep=10
         if(0.ne.iscns(ibuf(4),1,nchar-6,istatk4,1,4))then
            isleep=20
         else if(0.ne.iscns(ibuf(4),1,nchar-6,ilvk4,1,2)) then
            isleep=70
         else if(0.ne.iscns(ibuf(4),1,nchar-6,ilck4,1,2).or.
     $           0.ne.iscns(ibuf(4),1,nchar-6,irdk4,1,2)) then
            isleep=0
         endif
         call fc_rte_sleep(isleep)
C
         if(imode.eq.7.or.imode.eq.11) then
            ibin=0
            imax=ilimit
         else if(imode.eq.8) then
            ibin=1
            imax=ilimit
         endif
         call fs_get_kecho(kecho)
         ireg = rddev(ibin,idevid(idev),ibuf,imax,ierr,ipcode,300,
     &        no_after,kecho)
         if (ierr .eq. -4) then
            idum=ichmv(ipcode,1,modtbl(1,idev),1,2)
         endif
         if (ierr .LT. 0) goto 910 !! GPIB READ ERROR CONDITION

C     IREG number of characters in the buffer

         if (ireg .GT. ilen) then
            ierr = -321 
            goto 910
         endif

         nclrer = nclrer + 1
         idum = ichmv(ibuf2,3,ibuf,1,ireg)
         ibuf2(1) = nadev       !!MNEMONIC DEVICE NAME 
         call put_buf(iclasr,ibuf2,-ireg-2,'  ','  ')
         if(imode.eq.11) then
            nclrer = nclrer + 1
            call put_buf(iclasr,centisec,-8,'  ','  ')
         endif
      else if(imode.eq.9) then
         call fs_get_kecho(kecho)
         ireg=statbrd(ibuf,ierr,ipcode,300,kecho)
         if (ierr .eq. -4) then
            idum=ichmv_ch(ipcode,1,'  ')
         endif
         if (ierr .LT. 0) goto 910 !! GPIB READ ERROR CONDITION
         nclrer = nclrer + 1
         idum = ichmv(ibuf2,3,ibuf,1,INT_CHARS)
         ibuf2(1) = nadev       !!MNEMONIC DEVICE NAME 
         call put_buf(iclasr,ibuf2,-2-INT_CHARS,'  ','  ')
      else if(imode.eq.10) then
         inxt=1
         do i=1,ndev
            if(idev.le.0.or.idev.eq.i) then
               if(and(modtbl(2,i),4).ne.0) then
                  call fs_get_kecho(kecho)
                  ireg=rspdev(idevid(i),ibuf,ierr,ipcode,300,kecho)
                  if (ierr .eq. -4) then
                     idum=ichmv_ch(ipcode,1,'  ')
                  endif
                  if (ierr .LT. 0) goto 910 !! GPIB READ ERROR CONDITION
                  inxt=ichmv(ibuf2(2),inxt,ibuf,1,INT_CHARS)
               else
                  inxt=ichmv(ibuf2(2),inxt,-2,1,INT_CHARS)
               endif
            endif
         enddo
         nclrer = nclrer + 1
         ibuf2(1) = nadev       !!MNEMONIC DEVICE NAME 
         call put_buf(iclasr,ibuf2,-1-inxt,'  ','  ')
      else if(imode.eq.12) then
         call fs_get_kecho(kecho)
         ireg=iclrdev(idevid(i),ierr,ipcode,300,kecho)
         if (ierr .eq. -4) then
            idum=ichmv_ch(ipcode,1,'  ')
         endif
         if (ierr .LT. 0) goto 910 !! GPIB READ ERROR CONDITION
      endif
C
C  9. END OF OUTER LOOP ON CLASS RECORDS.
C
      if(idev.gt.0) then
         call fc_rte_time(it,it(6))
         timlst(idev)=it(1)+it(2)*100.+it(3)*60.d2+it(4)*3600.d2
      endif
900   continue
c
910   continue
      if(kclear) call clrcl(iclass)
C
C 10. Now we have read all of the class records.  There may have
C     been an error in one record, and there may also be outstanding
C     response class numbers.  If so, do not send back partial classes
C     except in the case of mode 0. 
C 
C     IF NO ERROES, SEND ANY REPONSE CLASSES BACK TO BOSS

      if (ierr.ge.0 .OR. iclasr.eq.0) goto 1090	!! NO ERRORS
    
C     CLEAR ALL RESPONSE CLASSES
 
      call clrcl(iclasr)
      iclasr = 0
      nclrer = 0
C
1090  continue 

C     CLEAR INTERFACE IF AN ERROR OCCURED

      ip(1) = iclasr
      ip(2) = nclrer
      ip(3) = ierr
      ip(5) = ipcode
      call char2hol('ib',ip(4),1,2)
C
C*************************** SUSPEND HERE **********************
C
      if(ierr.eq.-322) kgpib=.false.
c
      goto 1
      end

