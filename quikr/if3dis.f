      subroutine if3dis(ip,iclcm)
C  if distributor display <880922.1239>
C 
C 1.1.   IF3DIS gets data from the IF3 distributor and displays it
C 
C 2.  IF3DIS INTERFACE 
C 
      dimension ip(1) 
C     INPUT VARIABLES:
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
C        IP(4)  - 
C        ICLCM  - class number of command buffer
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # RECS 
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C 2.5.   SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES: IFD
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf(30)                    ! input class buffer
      integer*2 ibuf2(30)                   ! output display buffer
      integer*2 ibuf1(10)                   ! matcn class buffer
      integer*4 freq                        ! long frequency 
      integer   isw(4)                      ! switch settings
      logical kcom,kdata,kbit
      dimension ireg(2)                     ! registers from exec calls
      integer get_buf
      equivalence (reg,ireg(1)) 
      integer nch                           ! character counter
C 
C 4.  CONSTANTS USED:
      parameter (ilen=60)                   ! length of buffers, characters
C 
C     PROGRAMMER: NRV
C     LAST MODIFIED: 800215 
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
      if (.not.kcom .and. (ierr.lt.0 .or. iclass.eq.0 .or. iclcm.eq.0))
     : return
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
      nch = ichmv_ch(ibuf2,nch,'/')         ! put / to indicate a response
C 
      if (.not.kcom .and. .not.kdata) then
        do i=1,ncrec
          if (i.ne.1) nch=mcoma(ibuf2,nch)      ! commas separate parameters
          ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
          nchar = ireg(2)
          nch = ichmv(ibuf2,nch,ibuf(2),1,nchar-2)
C                   Move buffer contents into output list 
        enddo
      else
         if (kcom) then
            iat = iatif3_fs
            call fs_get_imixif3(imixif3)
            imix = imixif3
            do i=1,4
               isw(i)=iswif3_fs(i)
            enddo
            call fs_get_freqif3(freqif3)
            freq=freqif3
         else
            ireg(2) = get_buf(iclass,ibuf1,-10,idum,idum)
            ireg(2) = get_buf(iclass,ibuf,-10,idum,idum)
C 
C     3. Now the buffer contains: IFD=, and we want to add the data.
C 
            call ma2i3(ibuf1,ibuf,iat,imix,isw(1),isw(2),isw(3),isw(4),
     &           iswp,freq,irem,ilo,tpi)
         endif
C     
         ierr = 0
         nch = nch + ib2as(iat,ibuf2,nch,o'100000'+2) ! attenuator setting
         nch = mcoma(ibuf2,nch)
         nch = iif3ed(-1,imix,ibuf2,nch,ilen) ! encode mixer state
         do i=1,4
            nch = mcoma(ibuf2,nch)
            if(kbit(iswavif3_fs,i))then
               nch = nch + ib2as(isw(i),ibuf2,nch,1) ! encode switches
            endif
         enddo
c     
         nch = mcoma(ibuf2,nch)
         if (.not.kcom) then
            nch = iif3ed(-2,iswp,ibuf2,nch,ilen) ! switch box present
         endif
         nch = mcoma(ibuf2,nch)
c
         inf=freq/100
         nch=nch+ib2as(inf,ibuf2,nch,z'8000'+4)
         nch=ichmv_ch(ibuf2,nch,'.')
         inf=freq-inf*100
         nch=nch+ib2as(inf,ibuf2,nch,z'8000'+2)
         nch = mcoma(ibuf2,nch)
c
         if (.not.kcom) then
            nch = iif3ed(-3,irem,ibuf2,nch,ilen) ! encode remote/local
            nch = mcoma(ibuf2,nch)
            nch = iif3ed(-4,ilo,ibuf2,nch,ilen) ! encode remote/local
            nch = mcoma(ibuf2,nch)
            nch = nch + ir2as(tpi,ibuf2,nch,6,0) - 1
         endif
      endif
C 
C     5. Now send the buffer to SAM and schedule PPT. 
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
      if (.not.kcheck) ierr = 0 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('q+',ip(4),1,2)

      return
      end 
