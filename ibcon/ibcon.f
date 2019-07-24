      program ibcon
C 
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
C                   1=read data, device mnemonic in word 2
C                   2=write data, device in word 2, data in words 3 - end 
C        IP2    - number of records in class
C 
C     OUTPUT VARIABLES:   (RMPAR) 
C 
C        IP1    - "EN" (we are ENding)
C        IP2    - "IB" (who we are) 
C        IP3    - class number of output buffer 
C        IP4    - number of records in class
C        IP5    - error code
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
      integer ireg 
      parameter (ibufln= 20)
      integer*2 ibuf(ibufln),ibuf2(ibufln)
C               - buffers for reading, writing
C        ILEN   - length of above buffers 
      logical kini
C               - TRUE once we have initialized 
C        NDEV   - # devices in module table 
      parameter (idevln=32)
C        length of device file names, up to 64 characters
      parameter (imaxdev=16)
C        maximum number of devices on IEEE board
      integer iscn_ch, ichmv, icomma, iend, iflch
      integer idlen
      integer rddev
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
      data kini/.false./
      data minmod/0/, maxmod/2/
      data ilen/40/
C
C 6.  PROGRAMMER: NRV
C                 LNF - SET TIMEOUT RETURN TO USER
C     LAST MODIFIED:  791129
C  WHO  WHEN    DESCRIPTION
C  GAG  901220  Added a call to logit on error condition when initializing
C               MODTBL
C
C     PROGRAM STRUCTURE
C
C     1. First get parameters and initialize if necessary.
C
      call setup_fscom
      call read_fscom
1     call wait_prog('ibcon',ip)
      iclass = ip(1)
      nclrec = ip(2)
      iclasr = 0
      nclrer = 0
      ierr = 0
C                   Initialize return class and number of records 
      if (iclass.eq.0) then
        ierr = -1 
        goto 1090 
      endif
C 
      if (kini) goto 200
C 
C     1.5  Read in device address table.
C     Read table from class buffer
C 
      do i=1,nclrec
        call ifill_ch(ibuf,1,ibufln,' ')
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
      if (nclrec.gt.imaxdev) call logit7(0,0,0,1,-101,2hib,imaxdev)
C
      ndev = min0(nclrec,imaxdev)
C
      call fs_get_idevgpib(idevgpib)
      ingpib = iflch(idevgpib,idevln)
      call opbrd(idevgpib,ingpib,ierr)   !! OPEN BOARD
      if (ierr.ne.0) goto 1090     !! GPIB ERROR CONDITION
      do i=1,ndev   !! OPEN DEVICES
        idlen = iflch(moddev(1,i),idevln)
        call opdev(moddev(1,i),idlen,idevid(i),ierr)
        if (ierr.ne.0) goto 1090     !! GPIB ERROR CONDITION
      enddo
      kini = .true.
      goto 1090
C
C
C  2. Begin the loop over class buffer records.
C     Read in the buffer, get the mode and module code.
C     Search the module table for a match.
C 
200   do 900 iclrec = 1,nclrec
        call ifill_ch(ibuf,1,ibufln,' ')
        ireg = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg 
        imode = ibuf(1) 
        if (imode.lt.minmod.or.imode.gt.maxmod) then
          ierr = -2 
          goto 900
        endif
C  CHECK DEVICE NAME (FIRST WORD)
      do i=1,ndev 
        if (ichcm(modtbl(1,i),1,ibuf(2),1,2).eq.0) goto 221
      end do
      ierr = -3 
      goto 900
221   idev = i
      nadev = modtbl(1,i)
      imdev = modtbl(2,i)
C
      if (imode.eq.2) goto 400
C
C  3. HERE WE ARE READING DATA FROM A DEVICE.
C
      if (imdev.ne.0.and.imdev.ne.1) then
        ierr = -6   !! LISTEN-ONLY DEVICE
        goto 900
      endif

C     write(6,102) idevid(idev),nadev
C102   format(" IBCON: reading from device ",i2,"(",a2,")")
      ireg = rddev(idevid(idev),ibuf,ibufln,ierr)
C DEBUG!
C     ireg = 17
C     call char2hol(' +23.456 -54.321',ibuf,1,15)
C
      if (ierr.ne.0) then     !! GPIB ERROR CONDITION
        if (ierr.eq.-8) call logit7(0,0,0,1,-201,2hib,ireg)
        goto 900
      endif
C
cxx     nch2 = ireg -2  !!strip off CR LF
      nch2=ireg
      if (nch2.le.0) goto 900
      nclrer = nclrer + 1
      idum = ichmv(ibuf2,3,ibuf,1,nch2)
      ibuf2(1) = nadev
      ireg=ireg+2
      call put_buf(iclasr,ibuf2,-nch2-2,0,0)
C     write(6,105) (ibuf2(inv),inv=2,20)
C105   format("IBCON: read from device: ",20a2)
      goto 900
C
C
C  4. HERE WE ARE WRITING DATA TO THE HPIB.
C
400   if (imdev.ne.0.and.imdev.ne.2) then
        ierr = -7  !! TALK-ONLY DEVICE
        goto 900
      endif
C
      if (nchar.le.4) then
        ierr = -9   !! WE HAVE NO DATA TO WRITE
        goto 900
      endif
C
      nchar = nchar - 4
c     write(6,100) idevid(idev),nadev,nchar,(ibuf(inv),inv=3,20)
100   format("IBCON: Writing to device ",i2,"(",a2,"),nchar=",
     .i2,"buf=",20a2)
      call wrdev(idevid(idev),ibuf(3),nchar,ierr)
C
C  9. END OF OUTER LOOP ON CLASS RECORDS.
C
900     continue
C
C 10. Now we have read all of the class records.  There may have
C     been an error in one record, and there may also be outstanding
C     response class numbers.  If so, do not send back partial classes
C     except in the case of mode 0. 
C 
      if (ierr.ge.0) goto 1090
C IF THERE WAS NO ERROR SEND ANY RESPONSE CLASSES ON BACK TO BOSS. 
      if (iclasr.eq.0) goto 1090
      do i=1,nclrer
        call ifill_ch(ibuf,1,ibufln,' ')
        ireg = get_buf(iclasr,ibuf,-ilen,idum,idum) 
      enddo
C CLEAR OUT ALL RESPONSE CLASSES
      iclasr = 0
      nclrer = 0
C
1090  ip(1) = iclasr
      ip(2) = nclrer
      ip(3) = ierr
      call char2hol('ib',ip(4),1,2)
C*************************** SUSPEND HERE **********************
C
C      write(6,103) iclasr,ierr
C103   format(" IBCON: returning class=",i5,", ierr=",i5)
      goto 1
      end
