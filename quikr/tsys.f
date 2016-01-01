      subroutine tsys(ip,nsub)
C  calc system temps c#870115:04:45#
C 
C     TSYS calculates the system temps and displays them
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C               - parameters from SLOWP 
C        IP(1)  - class number of input command buffer
C        IP(2-5)- not used
C 
C     OUTPUT VARIABLES: 
C        IP(1) - class for response 
C        IP(2) - number of records in class 
C        IP(3) - IERR 
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: TPLIS
C 
C 3.  LOCAL VARIABLES 
      dimension itpis(17) 
      integer itpis_vlba(MAX_DET) 
      integer itpis_lba(2*MAX_DAS) 
      integer itpis_dbbc(MAX_DBBC_DET) 
      integer itpis_norack(2)
C      - which TPIs to read back, filled in by TPLIS
C        ICH    - character counter 
C     NCHAR  - character count
      integer*2 ibuf((10+MAX_DET*12)/2)  ! class buffer, holding command
c                              CALTEMPS/32(xx,xxxxxxxx,) +\0
c                          197=(10+32x12)/2                    
      dimension ireg(2)                   !  registers from exec calls
      character*1 cjchar
      integer*2 lwho,lwhat(17)
      integer get_buf
      logical kskip
      real epoch, flux, corr
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/394/ ! 10+MAX_DET*12 !  length of ibuf, characters
      data lwho/2hqk/
      data lwhat/2hv1,2hv2,2hv3,2hv4,2hv5,2hv6,2hv7,2hv8,2hv9,
     &           2hva,2hvb,2hvc,2hvd,2hve,2hi1,2hi2,2hi3/
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:  810423
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920714  Made Mark IV a valid rack along with Mark III.
C 
C 
C     1. Call TPLIS to parse the command for us.  Check for errors. 
C     If none, we have the requested TPI readings in ITPIS. 
C     Then start fixing up the output buffer for the response.
C 
      ilen=10+MAX_DET*12         !  length of ibuf, characters
      ierr = 0
      indtmp = mod(nsub-4 ,10)
C                   Pick up the Tsys1 or 2 index
      call fs_get_rack(rack)

      if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
        call tplis(ip,itpis)
      else if (VLBA .eq.rack.or.VLBA4.eq.rack) then
        call tplisv(ip,itpis_vlba)
      else if (LBA.eq.rack) then
        call tplisl(ip,itpis_lba)
      else if (DBBC.eq.rack.and.
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       ) then
        call tplisd(ip,itpis_dbbc)
      else
        call tplisn(ip,itpis_norack)
      endif
      
      ierr = ip(3)
      iclass = 0
      nrec = 0
      if(ierr.ne.0) goto 990
C 
      ireg(2) = get_buf(ip(1),ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      nch = iscn_ch(ibuf,1,nchar,'=')
      if (nch.eq.0) nch=nchar+1 
      nch = ichmv_ch(ibuf,nch,'/')
C 
C     3. Loop over the TPIs, calculate Tsys, and add it to the
C     message for response. 
C 
      if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
         do i=1,17 
            if (itpis(i).ne.0) then
               j = i+14
               if(nsub.eq.5) then
                  kskip=.false.
                  if(i.le.14) then
                     kskip=iabs(ifp2vc(i)).lt.1.or.iabs(ifp2vc(i)).gt.3
                  endif
                  if (kskip) then
                     t = -1.0
                  else if (tpidiff(j).lt.0.5.or.tpidiff(j).gt.65534.5
     &                    .or.tpzero(j).lt.0.5.or.
     &                    tpsor(j).lt.0.5.or.tpsor(j).gt.65534.5) then
                     t= 1d9
                  else
                     t = (tpsor(j)-tpzero(j))*caltemps(j)/tpidiff(j)
                  endif
                  systmp(j) = t
                  if((t.ge.999999.95.or.t.lt.0).and..not.kskip) then
                     call logit7(idum,idum,idum,-1,-211,lwho,lwhat(i)) 
                  endif
               else if(nsub.eq.6) then
                  tpidiff(j)=tpspc(j)-tpsor(j)
                  if (tpspc(j).gt.65534.5.or.tpsor(j).gt.65534.5.or.
     &                 tpspc(j).lt.0.5.or.tpsor(j).lt.0.5) then
                     tpidiff(j)= 1d9
                  endif
               else if(nsub.eq.10) then
                  epoch=-1.0
                  call fc_get_tcal_fwhm(lwhat(i),caltemps(j),fwhm,
     &                 epoch,flux,corr,ssize,ierr)
                  ierr=0
               endif
            endif
         enddo
         call fs_set_systmp(systmp)
         call fs_get_itpivc(itpivc)
         nchstart=nch
         iclass=0
         nrec=0
         do j=0,3
            do i=1,14
               if (itpis(i).ne.0.and.iabs(ifp2vc(i)).eq.j) then
                  if(nch.ge.60) then
                     call put_buf(iclass,ibuf,2-nch,'fs','  ')
                     nrec=nrec+1
                     nch=nchstart
                  endif
                  nch=ichmv(ibuf,nch,ih22a(i),2,1)
                  if(itpivc(i).eq.-1) then
                     nch=ichmv_ch(ibuf,nch,'x')
                  elseif(itpivc(i).eq.0) then
                     nch=ichmv_ch(ibuf,nch,'d')
                  elseif(itpivc(i).eq.1) then
                     nch=ichmv_ch(ibuf,nch,'l')
                  elseif(itpivc(i).eq.2) then
                     nch=ichmv_ch(ibuf,nch,'u')
                  else
                     nch=nch+ib2as(and(itpivc(i),7),ibuf,nch,1)
                  endif
                  nch = mcoma(ibuf,nch)
                  if(nsub.eq.5) then
                     nch = nch+ir2as(systmp(i+14),ibuf,nch,8,1)
                  else if(nsub.eq.6) then
                     nch = nch+ir2as(tpidiff(i+14),ibuf,nch,6,0)-1
                  else if(nsub.eq.10) then
                     nch = nch+ir2as(caltemps(i+14),ibuf,nch,8,3)
                  endif
                  nch = mcoma(ibuf,nch)
               endif
            enddo
            if(j.gt.0) then
               if(itpis(j+14).ne.0) then
                  if(nch.ge.60) then
                     call put_buf(iclass,ibuf,2-nch,'fs','  ')
                     nrec=nrec+1
                     nch=nchstart
                  endif
                  nch=ichmv_ch(ibuf,nch,'i')
                  nch=nch+ib2as(j,ibuf,nch,1)
                  nch = mcoma(ibuf,nch)
                  if(nsub.eq.5) then
                     nch = nch+ir2as(systmp(j+28),ibuf,nch,8,1)
                  else if(nsub.eq.6) then
                     nch = nch+ir2as(tpidiff(j+28),ibuf,nch,6,0)-1
                  else if(nsub.eq.10) then
                     nch = nch+ir2as(caltemps(j+28),ibuf,nch,8,3)
                  endif
                  nch = mcoma(ibuf,nch)
               endif
            endif
            if(nch.gt.nchstart) then
               call put_buf(iclass,ibuf,2-nch,'fs','  ')
               nrec=nrec+1
               nch=nchstart
            endif
         enddo
         goto 990
C     
      else if (VLBA .eq.rack.or.VLBA4.eq.rack) then
        call fc_tsys_vlba(ip,itpis_vlba,ibuf,nch,nsub)
        return
      else if (LBA.eq.rack) then
        call fc_tsys_lba(ip,itpis_lba,ibuf,nch,nsub)
        return
      else if (DBBC.eq.rack.and.
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       ) then
        call fc_tsys_dbbc(ip,itpis_dbbc,ibuf,nch,nsub)
        return
      else
        call fc_tsys_norack(ip,itpis_norack,ibuf,nch,nsub)
        return
      endif
C
      iclass = 0
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      nrec = 1
990   ip(1) = iclass
      ip(2) = nrec
      ip(3) = ierr
      call char2hol('qk',ip(4),1,2)
      return
      end 
