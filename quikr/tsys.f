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
      integer itpis_vlba(32) 
C      - which TPIs to read back, filled in by TPLIS
C        ICH    - character counter 
C     NCHAR  - character count
      integer*2 ibuf(156)               ! class buffer, holding command
      dimension ireg(2)                   !  registers from exec calls
      character*1 cjchar
      integer*2 lwho,lwhat(17)
      integer get_buf
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/312/                          !  length of ibuf, characters
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
      ierr = 0
      indtmp = mod(nsub-4 ,10)
C                   Pick up the Tsys1 or 2 index
      call fs_get_rack(rack)

      if((MK3.eq.and(rack,MK3)).or.(MK4.eq.and(rack,MK4))) then
        call tplis(ip,itpis)
      else if (VLBA .eq. and(rack,VLBA)) then
        call tplisv(ip,itpis_vlba)
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
      if((MK3.eq.and(rack,MK3)).or.(MK4.eq.and(rack,MK4))) then
         do i=1,17 
            if (itpis(i).ne.0) then
               j = i+14
               if (i.le.14) j=i+(itpivc(i)-1)*14
               if (j.lt.1 .or. j.gt.31) then
                  t = -1.0
               else if (abs(tpspc(j)-tpsor(j)).lt.0.5.or.
     &                 tpzero(j).lt.0.5.or. 
     &                 tpspc(j).gt.65534.5.or.
     &                 tpsor(j).gt.65534.5  ) then
                  t= 1d9
                  systmp(j) = t
               else
                  t = (tpsor(j)-tpzero(j))*caltmp(indtmp)/
     &                 (tpspc(j)-tpsor(j))
                  systmp(j) = t
               endif
               if (nch+5.le.ilen) then
C     Make sure we don't overstep our buffer
                  inextc=nch
                  nch = nch+ir2as(t,ibuf,nch,8,1)
                  nch = mcoma(ibuf,nch)
                  if(cjchar(ibuf,inextc).eq.'$'.or.
     &                 cjchar(ibuf,inextc).eq.'-') then
                     call logit7(idum,idum,idum,-1,-211,lwho,lwhat(i)) 
                  endif
               endif
            endif
         enddo
         call fs_set_systmp(systmp)
         nch = nch - 2 
C 
      else
        call fc_tsys_vlba(itpis_vlba,ibuf,nch, caltmp(indtmp))
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
