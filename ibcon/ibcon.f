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
      integer ireg,mode,ipcode
      parameter (ibufln= 128)
      integer*2 ibuf(ibufln),ibuf2(ibufln)
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
      integer idlen
      integer rddev
      integer idum,fc_rte_prior
      integer*2 moddev(imaxdev,idevln)
C               - module device name
      integer idevid(imaxdev)   
C               - device ids when opened
      integer*2 modtbl(2,imaxdev)  
C               - module table, word 1 = mnemonic, 
C                 word 2 = 0 for talk/listen devices
C                          1 for talk-only devices 
C                          2 for listen-only devices
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data kini/.false./,kfirst/.true./,kgpib/.true./
      data minmod/0/, maxmod/4/
      data ilen/256/
C
C
C     PROGRAM STRUCTURE
C
C     1. First get parameters and initialize if necessary.
C
      call setup_fscom
      call read_fscom
      idum=fc_rte_prior(FS_PRIOR)
1     call wait_prog('ibcon',ip)
      iclass = ip(1)
      nclrec = ip(2)
      iclasr = 0
      nclrer = 0
      ierr = 0
C
C                   Initialize return class and number of records 
      if (iclass.eq.0) then
        ierr = -1 
        goto 1090 
      endif
C
      if (.not.kfirst) goto 200
      kfirst=.false.
      if (kini) goto 200
C 
C     1.5  Read in device address table.
C     Read table from class buffer
C 
      do i=1,nclrec
        call ifill_ch(ibuf,1,ilen,' ')
        ireg = get_buf(iclass,ibuf,-ilen,idum,idum)
        if (i.le.imaxdev) then
          modtbl(1,i) = ibuf(1)
C !! FIND COMMA AND MOVE DEVICE NAME INTO VARIABLE
C !! IF THERE IS A COMMA, MOVE OPTION INTO VARIABLE 
          icomma = iscn_ch(ibuf,4,ireg,',') 
          if (icomma.eq.0) then
            iend=ireg+1 
            modtbl(2,i) = 0
          else
            iend = icomma
            modtbl(2,i) = ias2b(ibuf,icomma+1,1)
          endif
          idum = ichmv(moddev(1,i),1,ibuf,4,iend-4)
        endif
      enddo
      if (nclrec.gt.imaxdev) call logit7ci(0,0,0,1,-101,'ib',imaxdev)
C
      ndev = min0(nclrec,imaxdev)
C
      call fs_get_idevgpib(idevgpib)
      if(ichcm_ch(idevgpib,1,'/dev/null ').eq.0) then
         ierr = -12
         goto 1090
      endif
      ingpib = iflch(idevgpib,idevln)
      call opbrd(idevgpib,ingpib,ierr,ipcode)  	!! OPEN BOARD
      if (ierr.ne.0) goto 1090     		!! GPIB ERROR CONDITION
      do i=1,ndev   !! OPEN DEVICES
        idlen = iflch(moddev(1,i),idevln)
        call opdev(moddev(1,i),idlen,idevid(i),ierr,ipcode)
        if (ierr.ne.0) goto 1090     		!! GPIB ERROR CONDITION
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
        call ifill_ch(ibuf,1,ilen,' ')
        ireg = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg
	imode = ibuf(1)
        if (imode.lt.minmod.or.imode.gt.maxmod) then
          ierr = -2 
          goto 910
        endif
C  CHECK DEVICE NAME (FIRST WORD)
      do i=1,ndev 
        if (ichcm(modtbl(1,i),1,ibuf(2),1,2).eq.0) goto 221
      end do
      ierr = -3 
      goto 910
221   idev = i
      nadev = modtbl(1,i)
      imdev = modtbl(2,i)
C
      if (imode.EQ.2 .OR. imode.EQ.4) goto 400	!! JUMP ON A WRITE REQUEST 
C
C  3. HERE WE ARE READING DATA FROM A DEVICE.
C
      if (imdev.NE.0 .AND. imdev.NE.2) then
        ierr = -6   !! LISTEN-ONLY DEVICE
        goto 910
      endif

      ireg = rddev(imode,idevid(idev),ibuf,ilen,ierr,ipcode)
      if (ierr .eq. -4) then
        idum=ichmv(ipcode,1,modtbl(1,idev),1,2)
      endif
      if (ierr .LT. 0) goto 910      		!! GPIB READ ERROR CONDITION

C     IREG number of characters in the buffer

      if (ireg .GT. ilen) then
        ierr = -321 
        goto 910
      endif

      nclrer = nclrer + 1
      idum = ichmv(ibuf2,3,ibuf,1,ireg)
      ibuf2(1) = nadev				!!MNEMONIC DEVICE NAME 
      call put_buf(iclasr,ibuf2,-ireg-2,'  ','  ')
      goto 900
C
C
C  4. HERE WE ARE WRITING DATA TO THE HPIB.
C
400   if (imdev.NE.0 .AND. imdev.NE.2) then
        ierr = -7  				!! TALK-ONLY DEVICE
        goto 910
      endif
C
      if (nchar.le.4) then
        ierr = -9   				!! NO DATA TO WRITE
        goto 910
      endif
C
      call wrdev(imode,idevid(idev),ibuf(3),nchar-4,ierr,ipcode)
      if (ierr .eq. -4) then
        idum=ichmv(ipcode,1,modtbl(1,idev),1,2)
      endif

      if (ierr .LT. 0) goto 910     		!! GPIB WRITE ERROR CONDITION

C
C  9. END OF OUTER LOOP ON CLASS RECORDS.
C

900   continue

910   call clrcl(iclass)
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

C*************************** SUSPEND HERE **********************


      if (ierr .EQ. -4) then
	call ifclr(ierr,ipcode) 
	if (ierr .LT. 0) call logit7ci(0,0,0,1,ierr,'ib',ipcode)
        if (ierr .EQ. -300) then
          call get_ibcnt(ibcnt)
          call logit7ci(0,0,0,1,-9,'ib',ibcnt)
        endif
      else if (ierr .EQ. -300) then
        call get_ibcnt(ibcnt)
        call logit7ci(0,0,0,1,-9,'ib',ibcnt)
      endif
      if(ierr.eq.-322) kgpib=.false.
c
      goto 1
      end

