      subroutine vcdis(ip,ivcn,iclcm)
C  vc display <880922.1238>
C 
C 1.1.   VCDIS gets data from a Video Converter and displays it 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - # records in class
C        IP(3)  - error return from MATCN 
C        IP(4)  - who, or o'77' (?) 
C        IP(5)  - class with command
C 
C     OUTPUT VARIABLES: 
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibufv1(20),ibufv2(20),ibuf2(30) 
C               - input class buffers, output display buffer
C        ILEN   - length of buffers, chars
C        IBW    - bandwidth index 
C        ITP    - total power index 
C        IVCN   - which VC
C        NCH    - character counter 
C        IATU,IATL
C               - attenuator settings 
C        IREM,ILOK
C               - remote, lock indicators 
      logical kcom,kdata
      dimension lfr(3)
      dimension ireg(2) 
      real extbw
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/40/,ilen2/60/ 
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:   790216 
C 
C     PROGRAM STRUCTURE 
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
C     of output buffer.  Get first buffer from MATCN. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen2,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      kdata = (nch.eq.0)
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
      do i=1,ncrec
        if (i.ne.1) nch=mcoma(ibuf2,nch)
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibufv1,-ilen,idum,idum)
        nchar = ireg(2) 
        nch = ichmv(ibuf2,nch,ibufv1(2),1,nchar-2)
C                   Move buffer contents into output list 
      enddo
      goto 500
C 
230   ireg(2) = get_buf(iclass,ibufv1,-ilen,idum,idum)
      ireg(2) = get_buf(iclass,ibufv2,-ilen,idum,idum)
C                   Get the two buffers with data 
C 
C 
C     3. Now the buffer contains: VCnn/, and we want to add the data. 
C 
300   call ma2vc(ibufv1,ibufv2,lfr,ibw,itp,iatu,iatl,iremvc(ivcn),
     .     ilokvc(ivcn),rtpivc,ial)
      call fs_set_ilokvc(ilokvc)
      extbw=-1.0
      goto 320
c
 310  continue
      call fs_get_lfreqv(lfreqv)
      idumm1 = ichmv(lfr,1,lfreqv(1,ivcn),1,6)
      call fs_get_ibwvc(ibwvc)
      ibw = ibwvc(ivcn) 
      if(ibw.eq.0) then
         call fs_get_extbwvc(extbwvc)
         extbw=extbwvc(ivcn)
      endif
      itp = itpivc(ivcn)
      iatu = iatuvc(ivcn) 
      iatl = iatlvc(ivcn) 
C 
320   ierr = 0
      nch = ichmv(ibuf2,nch,lfr,1,6)
C                   Move in frequency 
      if (ichcm(lfr,1,lfreqv(1,ivcn),1,6).ne.0) ierr = -301 
      nch = mcoma(ibuf2,nch)
C 
      nch = ivced(-1,ibw,extbw,ibuf2,nch,ilen2) 
C                   Convert real number bandwidth to characters 
      call fs_get_ibwvc(ibwvc)
      if (ibw.ne.ibwvc(ivcn)) ierr = -302 
      nch = mcoma(ibuf2,nch)
C 
      nch = ivced(-2,itp,extbw,ibuf2,nch,ilen2) 
C                   Total power selection, ASCII letters
      if (itp.ne.itpivc(ivcn)) ierr = -303
      nch = mcoma(ibuf2,nch)
C 
      ncx = ib2as(iatu,ibuf2,nch,o'100000'+2) 
      if (iatu.ne.iatuvc(ivcn)) ierr = -304 
      nch = mcoma(ibuf2,nch+ncx)
      ncx = ib2as(iatl,ibuf2,nch,o'100000'+2) 
      if (iatl.ne.iatlvc(ivcn)) ierr = -305 
C 
      nch = nch + ncx 
      if (kcom) goto 500
C 
      nch = mcoma(ibuf2,nch)
C 
      nch = ivced(-3,iremvc(ivcn),extbw,ibuf2,nch,ilen2)
C                   Remote setting
      nch = mcoma(ibuf2,nch)
C 
      call fs_get_ilokvc(ilokvc)
      nch = ivced(-4,ilokvc(ivcn),extbw,ibuf2,nch,ilen2)
C                   Oscillator locked or not
      nch = mcoma(ibuf2,nch)
C 
      nch = nch + ir2as(rtpivc,ibuf2,nch,6,0) - 1
C                   Total power reading, binary 
C 
C 
C     5. Now send the buffer to SAM and schedule PPT. 
C 
500   iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C                   Send buffer starting with VC= for display.
      if (.not.kcheck) ierr = 0 
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qv',ip(4),1,2)
      ip(5) = 0 

      return
      end 
