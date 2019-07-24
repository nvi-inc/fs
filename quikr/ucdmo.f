      subroutine ucdmo(ip,iclcm)
C  uc display <910212.1738>
C
C     UCDMO gets data from the receiver and displays it
C
C     INPUT VARIABLES:
C
      dimension ip(1)
C        IP(1)  - class number of buffer from MATCN
C        IP(2)  - # records in class
C        IP(3)  - error return from MATCN
C        IP(4)  - who, or o'77' (?)
C        IP(5)  - class with command
C
C     OUTPUT VARIABLES:
C
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are
C
C 2.2.   COMMON BLOCKS USED
C
      include '../include/fscom.i'
C
C 2.5   CALLED SUBROUTINES: character utilities
C
C 3.  LOCAL VARIABLES
C
C     IAD - A/D channel
C     IDCAL - delay cal heater
C     ICAL - cal status
      dimension lc(3)
C     IBOX - box heater
C     ILO - LO status
C     NCH    - character counter
C
      integer*2 lunlk(8)
      logical kcom,kdata
      dimension ireg(2)          ! registers from exec
      integer get_buf
      equivalence (reg,ireg(1)) 
      integer*2 ibuf1(20),ibuf2(30) 
C               - input class buffers, output display buffer
C 
C 4.  CONSTANTS USED
      parameter (ilen=40, ilen2=60)     !  buffer lengths, characters
C 
C 5.  INITIALIZED VARIABLES 
C 
      data lunlk /o'015446',2hdb,2hun,2hlo,2hck,2hed,o'015446',2hd@/  
C 
C 6.  PROGRAMMER: NRV  CREATED 830610 AT MOJAVE 
C 
C     WHO  WHEN    WHAT 
C     WEH  830617  ADDED LOOKUP TABLE FOR 20K NOISE DIODE 
C                  FIXED TO DISPLAY EXACTLY 4 SIGNIFICANT DIGITS
C     NRV  840509  MADE CHANGES FOR NEW VERSION 
C                  USE SAME TABLE FOR 70K AS FOR 20K
C                  PRESSURE FORMULA FROM BEC
C     MWH  850121  PUT 'UNLOCKED' MESSAGE IN INVERSE VIDEO
C     LAR  880227  MOVE VOLTAGE-TO-WEATHER CONVERSION TO RXVTOT
C 
C 
C     1. Determine whether parameters from COMMON wanted and skip to
C     response section. 
C     Get RMPAR parameters and check for errors from our I/O request. 
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
C 
      if (.not.kcom.and.(ierr.lt.0.or.iclass.eq.0.or.iclcm.eq.0)) return
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get buffer from MATCN. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen2,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = nch.eq.0
C                   If our command was only "device" we are waiting for 
C                   data and know what to expect. 
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv(ibuf2,nch,2h/ ,1,1)    ! put "/" to indicate a response
C 
      if (.not.kcom) then
        if (.not.kdata) then
          do i=1,ncrec
            if (i.ne.1) nch=mcoma(ibuf2,nch)
C                   If not first parm, put comma before
            ireg(2) = get_buf(iclass,ibuf1,-ilen,idum,idum)
            nchar = ireg(2)
            nch = ichmv(ibuf2,nch,ibuf1(2),1,nchar-2)
C                   Move buffer contents into output list
          enddo
          goto 500
        endif
C
        ireg(2) = get_buf(iclass,ibuf1,-ilen,idum,idum)
        call ma2uc(ibuf1(2),lostst,ical,idcal,iloh,ibox,iadc,vadc)
      else
        iadc = iadcst                ! read values from field system common
        ical = lswcal
        idcal = idchst
        iloh = ilohst
        ibox = ibxhst
      endif
      ierr = 0
      ia = 1 + ia22h(iadc)
C
C     3. Now the buffer contains: UC/, and we want to add the data. 
C 
      call char2hol('-1',iad,1,2)
      idumm1 = ichmv(lc,1,5hundef,1,5)
      nl = 5
      if (ia.ne.0) then
        nl = iflch(lcode(1,ia),6)
        iad = iadc
        idumm1 = ichmv(lc,1,lcode(1,ia),1,nl)
      endif
      nch = ichmv(ibuf2,nch,iad,1,2)
      nch = ichmv(ibuf2,nch,2h( ,1,1)
      nch = ichmv(ibuf2,nch,lc,1,nl)
      nch = ichmv(ibuf2,nch,2h) ,1,1)
      nch = mcoma(ibuf2,nch)
      if (idcal.eq.0) nch = ichmv(ibuf2,nch,3hoff,1,3)
      if (idcal.eq.1) nch = ichmv(ibuf2,nch,2hon,1,2)
      nch = mcoma(ibuf2,nch)
      if (iloh.eq. 0) nch = ichmv(ibuf2,nch,3hoff,1,3)
      if (iloh.eq. 1) nch = ichmv(ibuf2,nch,2hon,1,2)
      nch = mcoma(ibuf2,nch)
      if (ibox.eq. 0) nch = ichmv(ibuf2,nch,3hoff,1,3)
      if (ibox.eq. 1) nch = ichmv(ibuf2,nch,2hon,1,2)
      nch = mcoma(ibuf2,nch)
      do i=1,3
        if (ifamst(i).eq.0) nch=ichmv(ibuf2,nch,3hoff,1,3)
        if (ifamst(i).eq.1) nch=ichmv(ibuf2,nch,2hon,1,2)
        nch=mcoma(ibuf2,nch)
      enddo
      if (ical.eq. 0) nch = ichmv(ibuf2,nch,3hoff,1,3)
      if (ical.eq. 1) nch = ichmv(ibuf2,nch,2hon,1,2)
      if (ical.eq. 2) nch = ichmv(ibuf2,nch,3hext,1,3)
      if (ical.eq.-1) nch = ichmv(ibuf2,nch,3hoon,1,3)
      if (ical.eq.-2) nch = ichmv(ibuf2,nch,4hooff,1,4)
      if (kcom) goto 500
      nch = mcoma(ibuf2,nch)
      if (lostst.eq.1) nch=ichmv(ibuf2,nch,6hlocked,1,6)
      if (lostst.eq.0) nch=ichmv(ibuf2,nch,lunlk,1,16)
      nch = mcoma(ibuf2,nch)
C
C   CONVERT TO ASCII, PUT THE NUMBER OF CHARACTERS INTO A DUMMY VARIABLE
C
      vadcst=vadc*vfac(ia)
C
      nchb= nch + ir2as(vadcst,ibuf2,nch,10,3)
C
C   PUT ONLY 4 SIGNIFICANT DIGITS + A DECIMAL POINT (+ A MINUS
C                                   SIGN IF NEGATIVE)
C   THIS IS MADE SIMPLE BY THE FACTS THAT IR2AS LEFT JUSTIFIES
C   AND THAT ALL THE NUMBERS WE WORK HAVE THE LEAST SIGNIFICANT
C   DIGIT TO THE LEFT OF THE .0001 DECIMAL PLACE
C   OTHERWISE WE WOULD NEED LOGS OR SOMETHING
C
      nch = nch + 5
      if (vadcst.lt.0) nch=nch+1
C 
C     5. Now send the buffer to BOSS for logging. 
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
C 
      ip(1) = iclass 
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qb',ip(4),1,2)
      ip(5) = 0 
      return
      end 
