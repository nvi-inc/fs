      subroutine repds4(ip,iclcm,indxtp)
C  reproduce display for Mark IV drive
C 
C  REPDS4 gets data about the reproduce tracks and displays it 
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C     COMMON BLOCKS USED
C 
      include '../include/fscom.i'
C 
C     CALLING SUBROUTINES:
C 
C     CALLED SUBROUTINES: character utilities 
C 
C    LOCAL VARIABLES
C 
      integer*2 ibuf(20),ibuf2(40), ibuf3(20)
C               - input class buffer, output display buffer 
      integer*2 lby(4)
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
      dimension ibws1(4), ibws3(5)
      logical kcom,kdata
C              - true if COMMON variables wanted
C 
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C    INITIALIZED VARIABLES
C 
      data ilen/40/
      data lby/2hre,2had,2hby,2hp /
      data ibws1/0,1,2,3/       !!! EQUALIZERS !!!
      data ibws3/16,8,4,2,1/   !!! BITRATES !!!
C
C  HISTORY:
C  WHO  WHEN    DESCRIPTION
C  gag  920728  Created by coping repds.
C
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
      if (ierr.lt.0) goto 990
      if (iclass.eq.0.or.iclcm.eq.0) goto 990 
C 
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from MATCN. 
C 
200   ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = min0(ireg(2),ilen)
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = nch.eq.0
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
        if (i.ne.1) nch=ichmv_ch(ibuf2,nch,',') 
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg(2) 
        nch = ichmv(ibuf2,nch,ibuf(2),1,nchar-2)
C                   Move buffer contents into output list 
220     continue
      goto 500
C 
230   ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      ireg(2) = get_buf(iclass,ibuf3,-ilen,idum,idum)
C                   Read record into display buffer
C
C
C     3.  Format of data received from tape controller:
C
      call ma2rp4(ibuf,iremtp,iby,ieq,ita,itb)
      call ma2rpbr4(ibuf3,ibr)
      goto 320
310   ita = itrakaus_fs(indxtp)
      itb = itrakbus_fs(indxtp)
      ibr = ibr4tap(indxtp)
      ieq = ieq4tap(indxtp)
      iby = ibypas(indxtp)
320   ierr = 0
      if (iby.eq.1) then
        nch = ichmv(ibuf2,nch,lby(iby*2+1),1,3)
      else
        nch = ichmv(ibuf2,nch,lby(iby*2+1),1,4)
      endif
C                   Bypass or not
      if (iby.ne.ibypas(indxtp)) ierr = -301
      nch = mcoma(ibuf2,nch)
C
      ncx = ib2as(ita,ibuf2,nch,o'100000'+3)
C                   Encode the A track
      call fs_get_itraka(itraka,indxtp)
      if (ita.ne.itraka(indxtp).and..not.kcom) ierr = -302
      nch = mcoma(ibuf2,nch+ncx)
C
      ncx = ib2as(itb,ibuf2,nch,o'100000'+3)
C                   Encode the B track
      call fs_get_itrakb(itrakb,indxtp)
      if (itb.ne.itrakb(indxtp).and..not.kcom) ierr = -303
      nch = mcoma(ibuf2,nch+ncx)
C
      if (ieq.eq.3) then
        nch = ichmv_ch(ibuf2,nch,'dis') 
      else
        ncx = ib2as(ibws1(ieq+1),ibuf2,nch,1)
        nch=nch+ncx
      endif
C                   The equalizer selection 
      if (ieq.ne.ieq4tap(indxtp)) ierr = -305
      nch = mcoma(ibuf2,nch)
      if(ibr.ge.1.and.ibr.le.5) then
        ncx = ib2as(ibws3(ibr),ibuf2,nch,o'100000'+2)
      else
        nch = ichmv_ch(ibuf2,nch,'bad_value') 
      endif
      nch=nch+ncx
C                   The bitrate for reproduce
      if (ibr.ne.ibr4tap(indxtp)) ierr = -306
C 
C     4. Now send the buffer to SAM.
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C                   Send buffer starting with TP to display 
      if (.not.kcheck) ierr = 0 
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qr',ip(4),1,2)
990   return
      end 
