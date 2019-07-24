      subroutine tpi(ip,isub)
C  sample tpis     <880922.1527>
C 
C   TPI gets the total power integrator readings and stores 
C     them in common. 
C 
C     DATE   WHO CHANGES
C     810909 NRV Added VC zero capability 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C               - parameters from SLOWP 
C        IP(1)  - class number of input parameter buffer
C        IP(2-5)- not used
C        ISUB   - which sub-function, 3=TPI, 4=TPICAL, 7=TPZERO 
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
C     CALLED SUBROUTINES: TPLIS,TPPUT,IF2MA
C
C 3.  LOCAL VARIABLES
      integer itpis(16)
      integer itpis_vlba(34)
C      - which TPIs to read back
C        ICH    - character counter
C     NCHAR  - character count
      parameter (ibufln=106)     ! worst case: TPZERO/34($$$$$,) + '\0'
      integer*2 ibuf(ibufln)     !         106 =(  7  + 34*6 + 1)/2
C               - class buffer, holding command
C        ILEN   - length of IBUF, chars
      dimension ireg(2)
      integer get_buf
C               - registers from EXEC calls
      integer*2 lvcn(15)
C               - VC names
C
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/120/
      data lvcn   /2Hv1,2Hv2,2Hv3,2Hv4,2Hv5,2Hv6,2Hv7,2Hv8,2Hv9,2Hva, 
     /             2Hvb,2Hvc,2Hvd,2Hve,2Hvf/
C 
C 
C     PROGRAM STRUCTURE 
C 
C     1. Call TPLIS to parse the command for us.  Check for errors. 
C     If none, we have the requested TPI readings in ITPIS. 
C
      iclcm = ip(1)
      if (iclcm.eq.0) return
C                     Retain class for later response
      call fs_get_rack(rack)

      if (MK3 .eq. iand(rack,MK3)) then
        call tplis(ip,itpis)
      else if (VLBA .eq. iand(rack,VLBA)) then
        call tplisv(ip,itpis_vlba)
      endif
C
      ierr = ip(3)
      iclass = 0
      nrec = 0
      if (ierr.ne.0) goto 990
C
C     2. Now we are ready to send the big message to MATCN.
C     For each TPI requested, request the appropriate data.
C
      nrec = 0
      iclass = 0

      if (MK3 .eq. iand(rack,MK3)) then

        do i=1,16
         if(itpis(i).ne.0.and.(i.le.15.or.(i.eq.16.and.itpis(15).eq.0)))
     &      then
            if (i.le.14) then
              ibuf(1) = -2
              ibuf(2) = lvcn(i)
            else
              ibuf(1) = -1
              call char2hol('if',ibuf(2),1,2)
            endif
            call put_buf(iclass,ibuf,-4,2hfs,0)
            nrec = nrec + 1
          endif
        enddo
C
        call run_matcn(iclass,nrec)
        call rmpar(ip)
        if (ip(3).lt.0) return

      else if (VLBA .eq. iand(rack,VLBA)) then
        call fc_tpi_vlba(ip,itpis_vlba)
        if(ip(3).lt.0) return
      endif
C
C     5. Send the results to TPPUT for putting into COMMON.
C     Send back the response.
C     If this was a ZERO command, re-set the IFD.
C
      call ifill_ch(ibuf,1,ibufln*2,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) ieq=nchar+1
      nch = ichmv(ibuf,ieq,2h/ ,1,1)
C                     Get the command part of the response set up
      if(MK3.eq.iand(rack,MK3)) then
        call tpput(ip,itpis,isub,ibuf,nch,ilen)
      else
        call fc_tpput_vlba(ip,itpis_vlba,isub,ibuf,nch,ilen)
        if(ip(3).lt.0) return
      endif
      iclass = 0
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      nrec = 1
C
990   ip(1) = iclass
      ip(2) = nrec
      ip(3) = ierr
      call char2hol('qk',ip(4),1,2)
      return
      end
