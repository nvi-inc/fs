      subroutine repds(ip,iclcm)
C  reproduce display c#870115:04:40#
C 
C    REPDS gets data about the reproduce tracks and displays it 
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
C     CALLING SUBROUTINES: SLOWP
C 
C     CALLED SUBROUTINES: character utilities 
C 
C    LOCAL VARIABLES
C 
      integer*2 ibuf(20),ibuf2(40)
C               - input class buffer, output display buffer 
      integer*2 lby(4)
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
      dimension bws(8)
C                   Bandwidth choices, convert to ASCII 
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
      data lby/2hra,2hw ,2hby,2hp /
      data bws/0.0,0.0625,0.125,0.25,0.5,1.0,2.0,4.0/
C
C
C    PROGRAMMER: NRV
C     LAST MODIFIED: 800829
C  WHO  WHEN    DESCRIPTION
C  GAG  910201  Added use of user supplied track variable ITRAKAUS_FS
C               and ITRAKBUS_FS
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
      nch = ichmv(ibuf2,nch,2h/ ,1,1) 
C                   Put / to indicate a response
C 
      if (kcom) goto 310
      if (kdata) goto 230 
C 
      do 220 i=1,ncrec
        if (i.ne.1) nch=ichmv(ibuf2,nch,2h, ,1,1) 
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg(2) 
        nch = ichmv(ibuf2,nch,ibuf(2),1,nchar-2)
C                   Move buffer contents into output list 
220     continue
      goto 500
C 
230   ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
C                   Read record into display buffer
C
C
C     3.  Format of data received from tape controller:
C
C                  ! data in IBUF:   TPrdebtbta
C
      call ma2rp(ibuf,iremtp,iby,ieq,ibw,ita,itb,ial)
      call fs_set_iremtp(iremtp)
      goto 320
310   ita = itrakaus_fs
      itb = itrakbus_fs
      ibw = ibwtap
      ieq = ieqtap
      iby = ibypas
320   ierr = 0
      nch = ichmv(ibuf2,nch,lby(iby*2+1),1,3)
C                   Bypass or not
      if (iby.ne.ibypas) ierr = -301
      nch = mcoma(ibuf2,nch)
C
      ncx = ib2as(ita,ibuf2,nch,o'100000'+2)
C                   Encode the A track
      call fs_get_itraka(itraka)
      if (ita.ne.itraka.and..not.kcom) ierr = -302
      nch = mcoma(ibuf2,nch+ncx)
C
      ncx = ib2as(itb,ibuf2,nch,o'100000'+2)
C                   Encode the B track
      call fs_get_itrakb(itrakb)
      if (itb.ne.itrakb.and..not.kcom) ierr = -303
      nch = mcoma(ibuf2,nch+ncx)
C
      ncx = ir2as(bws(ibw+1),ibuf2,nch,6,4)
C                   The bandwidth for reproduce
      if (ibw.ne.ibwtap) ierr = -304
      nch = mcoma(ibuf2,nch+ncx)
C
      nch = nch + ir2as(bws(ieq+2),ibuf2,nch,6,4)
C                   The equalizer selection 
      if (ieq.ne.ieqtap) ierr = -305
C 
C 
C 
C     4. Now send the buffer to SAM.
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,2hfs,0)
C                   Send buffer starting with TP to display 
      if (.not.kcheck) ierr = 0 
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qr',ip(4),1,2)
990   return
      end 
