      subroutine tpdis(ip,iclcm)
C  display tape parameters c#870115:04:33#
C 
C 1.1.   TPDIS gets data from the TAPE and displays it
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
      integer*2 ibufs(20),ibufd(20),ibuf2(40),lgenx(2)
C               - input class buffers, output display buffer
C        ILEN   - length of output buffer, chars
C        ILENM   - length of input buffers, chars
C        NCH    - character counter
C        I      - bit, converted to 0 or 1
C        IA     - hex char from MAT
      logical kcom,kdata
C              - true if COMMON variables wanted
      dimension ireg(2)
      integer get_buf
C               - registers from EXEC
      equivalence (reg,ireg(1))
C
C 5.  INITIALIZED VARIABLES
      data ilen/80/,ilenm/40/
C
C 6.  PROGRAMMER: NRV
C     LAST MODIFIED: 800229
C  WHO  WHEN    DESCRIPTION
C  GAG  910111  Changed LFEET to LFEET_FS on call to MA2TP and 4 to 5
C               when moving LFEET_FS into buffer with ICHMV.
C  GAG  910114  Added check to see if first character in LFEET_FS is a
C               1 to decided to move either 4 or 5 characters.
C
C     PROGRAM STRUCTURE
C
C     1. First check error return from MATCN.  If not 0, get out
C     immediately.  If setup data wanted ( ? ), skip class read.
C 
      kcom = (ichcm_ch(ip(4),1,'?').eq.0)
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      nrec = 0
C 
      if (kcom) goto 200
      if (ierr.lt.0) return 
      if (iclass.eq.0.or.iclcm.eq.0) return 
C 
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from MATCN. 
C 
200   ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = .false.
      if (nch.eq.0) kdata = .true.
C                   If our command was only "device" we are waiting for 
C                   data and know what to expect. 
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv_ch(ibuf2,nch,'/') 
C                   Put / to indicate a response
C 
      if (kcom) goto 310
      if (kdata) goto 230 
C 
      do 220 i=1,ncrec
        if (i.ne.1) nch=mcoma(ibuf2,nch)
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibufd,-ilenm,idum,idum)
        nchar = ireg(2) 
        nch = ichmv(ibuf2,nch,ibufd(2),1,nchar-2) 
C                   Move buffer contents into output list 
220     continue
      goto 500
C 
230   continue
      ireg(2) = get_buf(iclass,ibufd,-ilenm,idum,idum)
C                   Read first record into display buffer 
      ireg(2) = get_buf(iclass,ibufs,-ilenm,idum,idum)
C                   Read next record into  settings buffer
C 
C 
C     3. Now the buffer contains: TAPE=, and we want to add the data.
C
      call ma2tp(ibufd,ilow,lfeet_fs,ifastp,icaptp,istptp,itactp,irdytp)
      call fs_set_icaptp(icaptp)
      call fs_set_istptp(istptp)
      call fs_set_irdytp(irdytp)
      call fs_set_itactp(itactp)
      call fs_set_lfeet_fs(lfeet_fs)
C
      call fs_get_drive(drive)
      if (MK3.eq.drive) then
        call ma2rp(ibufs,iremtp,iby,ieq,ibw,ita,itb,ial)
      else
         call ma2rp4(ibufs,iremtp,iby,ieq,ita,itb)
      endif
      goto 320
310   ilow = ilowtp
C
320   nch = itped(-5,ilow,lgenx,ibuf2,nch,ilen)
C                   Low tape setting
C
      if (kcom) goto 500
C
      nch = mcoma(ibuf2,nch)
C
C     IF (ICHCM(LFEET_FS,1,2H0 ,1,1).EQ.0) THEN
C       NCH = ICHMV(IBUF2,NCH,LFEET_FS,2,4)
C     ELSE
        call fs_get_lfeet_fs(lfeet_fs)
        nch = ichmv(ibuf2,nch,lfeet_fs,1,5)
C     END IF
C                   Move footage count into output
      nch = mcoma(ibuf2,nch)
C
      nch = itped(-6,ifastp,lgenx,ibuf2,nch,ilen)
C                   Fast speed button
      nch = mcoma(ibuf2,nch)
C
      call fs_get_icaptp(icaptp)
      nch = itped(-9,icaptp,lgenx,ibuf2,nch,ilen)
C                   Capstan status
      nch = mcoma(ibuf2,nch)
C
      call fs_get_istptp(istptp)
c     since -7 < 0 -- following itped decodes FROM istptp
      nch = itped(-7,istptp,lgenx,ibuf2,nch,ilen)
C                   Stop command status
      nch = mcoma(ibuf2,nch)
C 
      call fs_get_itactp(itactp)
      nch = itped(-4,itactp,lgenx,ibuf2,nch,ilen) 
C                   Tach lock status
      nch = mcoma(ibuf2,nch)
C 
      call fs_get_irdytp(irdytp)
      nch = itped(-8,irdytp,lgenx,ibuf2,nch,ilen) 
C                   Ready status
      nch = mcoma(ibuf2,nch)
C 
C                   Top bit is rem/lcl
      nch = itped(-3,iremtp,lgenx,ibuf2,nch,ilen) 
C 
C 
C     4. Now send the buffer to SAM.
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C                   Send buffer starting with TP to display 
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qt',ip(4),1,2)
      return
      end 
