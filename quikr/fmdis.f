      subroutine fmdis(ip,iclcm)
C  formatter display c#870115:04:35#
C 
C 1.1.   FMDIS gets data from the formatter and displays it 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 

      include '../include/fscom.i'

C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES: SLOWP
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf(30),ibuf2(30)
C               - input class buffer, output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
C        ISYN   - synch test bits 
C        I      - bit, converted to 0 or 1
C        INP    - input index 
C        IOUT   - output index
C        IRATE  - rate index
      dimension itim(10)
C               - buffer for ( data with time 
      logical kcom,kdata
C              - true if COMMON variables wanted
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/60/ 
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:   800215 
C# LAST COMPC'ED  870115:04:35 #
C 
C     PROGRAM STRUCTURE 
C 
C     1. First check error return from MATCN.  If not 0, get out
C     immediately.
C 
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      nrec = 0
C 
      if (.not.kcom.and.(ierr.lt.0.or.iclass.eq.0.or.iclcm.eq.0)) return
C 
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from MATCN. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = (nch.eq.0)
C                   If our command was only "device" we are waiting for 
C                   data and know what to expect. 
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv(ibuf2,nch,2h/ ,1,1) 
C                   Put / to indicate a response
C 
      if (kcom) goto 310
      if (kdata) goto 230 
C 
      do 220 i=1,ncrec
        if (i.ne.1) nch=mcoma(ibuf2,nch)
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg(2) 
        nch = ichmv(ibuf2,nch,ibuf(2),1,nchar-2)
C                   Move buffer contents into output list 
220     continue
      goto 500
C 
230   ireg(2) = get_buf(iclass,itim,-ilen,idum,idum)
C                   Read first response into time buffer
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
C                   Read second response into general buffer
C 
C 
C     3. Now the buffer contains: FM=, and we want to add the data. 
C     Format of data received from Formatter: 
C      ( data:      hhmmssss
C     where each letter represents a character: 
C                   hh = hours
C                   mm = minutes
C                   ss = seconds
C                   ss = fractional seconds 
C 
C      ) data:      bydddpsr
C     where 
C                   b = bits denoting rem/lcl, alarm, power status
C                   y = years 
C                   ddd = days
C                   p = run/set, +/- edge, synch test bits
C                   s = input, output selection 
C                   r = rate setting
C 
300   call ma2fm(ibuf,inp,imod,irate,isyn,
     .           itstfm,isgnfm,irunfm,iremfm,ipwrfm,ial)
      goto 320
310   inp = inpfm 
      imod = imodfm 
      irate = iratfm
      isyn = isynfm 
C 
320   ierr = 0
      nch = ifmed(-1,imod,ibuf2,nch,ilen) 
C                   Output matrix selection 
      if (imod.ne.imodfm) ierr = -301 
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-2,irate,ibuf2,nch,ilen)
C                   Sample rate 
      if (irate.ne.iratfm) ierr = -302
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-8,inp,ibuf2,nch,ilen)
C                   Input selection 
      if (inp.ne.inpfm) ierr = -303 
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-4,isyn,ibuf2,nch,ilen) 
C                   Synch test on or off
      if (isyn.ne.isynfm) ierr = -304 
C 
      if (kcom) goto 500
C 
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-5,itstfm,ibuf2,nch,ilen) 
C                   Put in OK or FAIL 
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-6,isgnfm,ibuf2,nch,ilen) 
C                   Synch edge sign 
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-7,irunfm,ibuf2,nch,ilen) 
C                   "RUN" or "SET" on front panel 
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-3,iremfm,ibuf2,nch,ilen) 
C                   Remote/local
      nch = mcoma(ibuf2,nch)
C 
      nch = ifmed(-9,ipwrfm,ibuf2,nch,ilen) 
C                   Power interrupt 
      nch = mcoma(ibuf2,nch)
C 
      nch = ichmv(ibuf2,nch,ibuf,4,4) 
C                   Pick up yddd
      nch = ichmv(ibuf2,nch,itim,3,6) 
C                   This is hhmmss
      nch = ichmv(ibuf2,nch,2h. ,1,1) 
      nch = ichmv(ibuf2,nch,itim,9,2) 
C                   Fractional seconds
C 
C 
C     5. Now send the buffer to SAM and schedule PPT. 
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
C                   Send buffer starting with FM to display 
      if (.not.kcheck) ierr = 0 
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qf',ip(4),1,2)
      return
      end 
