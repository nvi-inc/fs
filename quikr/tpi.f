*
* Copyright (c) 2020, 2023 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      subroutine tpi(ip,isub)
C  sample tpis     <880922.1527>
C 
C   TPI gets the total power integrator readings and stores 
C     them in common. 
C 
C  HISTORY:
C  WHO  WHEN    WHAT 
C  NRV  810909  Added VC zero capability 
C  gag  920714  Added Mark IV as a valid rack along with Mark III.
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C               - parameters from SLOWP 
C        IP(1)  - class number of input parameter buffer
C        IP(2-5)- not used
C        ISUB   - which sub-function, 3=TPI, 4=TPICAL, 7=TPZERO, 8=TPGAIN(BBCs)
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
      integer itpis(17)
      integer itpis_vlba(MAX_DET)
      integer itpis_dbbc(MAX_DBBC_DET)
      integer itpis_dbbc_pfb(MAX_DBBC_PFB_DET)
      integer itpis_dbbc3(MAX_DBBC3_DET)
      integer itpis_lba(2*MAX_DAS)
      integer itpis_norack(2)
C      - which TPIs to read back
C        ICH    - character counter
C     NCHAR  - character count
      parameter (ibufln=(8+MAX_DET*9)/2)
c                                ! worst case: TPZERO/36(xx,$$$$$,) + '\0'
      integer*2 ibuf(ibufln)     !         166 =(  7  + 36*9  + 1)/2
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
      call fs_get_rack_type(rack_type)
c
      if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
        call tplis(ip,itpis)
      else if (VLBA .eq. rack .or. VLBA4.eq.rack) then
        call tplisv(ip,itpis_vlba)
      else if (LBA.eq.rack) then
        call tplisl(ip,itpis_lba)
      else if (DBBC.eq.rack.and.
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       ) then
        call tplisd(ip,itpis_dbbc)
      else if (DBBC.eq.rack.and.
     &       (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &       ) then
        call tplisd_pfb(ip,itpis_dbbc_pfb)
      else if (DBBC3.eq.rack) then
        call tplisd3(ip,itpis_dbbc3)
      else
         call tplisn(ip,itpis_norack)
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

      if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
        do i=1,17
         if(itpis(i).ne.0.and.
     &      (i.ne.16.or.(i.eq.16.and.itpis(15).eq.0)) ) then
            if (i.le.14) then
              ibuf(1) = -22
              ibuf(2) = lvcn(i)
            else if (i.le.16) then
              ibuf(1) = -21
              call char2hol('if',ibuf(2),1,2)
            else
              ibuf(1) = -22
              call char2hol('i3',ibuf(2),1,2)
            endif
            call put_buf(iclass,ibuf,-4,'fs','  ')
            nrec = nrec + 1
          endif
        enddo
C
        call run_matcn(iclass,nrec)
        call rmpar(ip)
        if (ip(3).lt.0) return

      else if (VLBA .eq.rack.or.VLBA4.eq.rack) then
        call fc_tpi_vlba(ip,itpis_vlba,isub)
        if(ip(3).lt.0) return
      else if (LBA.eq.rack) then
        call fc_tpi_lba(ip,itpis_lba)
        if(ip(3).lt.0) return
      else if (DBBC.eq.rack.and.
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       ) then
        call fc_tpi_dbbc(ip,itpis_dbbc)
        if(ip(3).lt.0) return
      else if (DBBC.eq.rack.and.
     &       (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &       ) then
        call fc_tpi_dbbc_pfb(ip,itpis_dbbc_pfb)
         if(ip(3).lt.0) return
      else if (DBBC3.eq.rack) then
        call fc_tpi_dbbc3(ip,itpis_dbbc3)
        if(ip(3).lt.0) return
      else
         call fc_tpi_norack(ip,itpis_norack)
         if(ip(3).lt.0) return
      endif
C
C     5. Send the results to TPPUT for putting into COMMON.
C     Send back the response.
C
      call ifill_ch(ibuf,1,ibufln*2,' ')
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) ieq=nchar+1
      nch = ichmv_ch(ibuf,ieq,'/')
C                     Get the command part of the response set up
      if(MK3.eq.rack.or.MK4.eq.rack.or.LBA4.eq.rack) then
        call tpput(ip,itpis,isub,ibuf,nch)
        return
      else if (VLBA .eq.rack.or.VLBA4.eq.rack) then
        call fc_tpput_vlba(ip,itpis_vlba,isub,ibuf,nch,ilen)
        return
      else if (LBA.eq.rack) then
        call fc_tpput_lba(ip,itpis_lba,isub,ibuf,nch,ilen)
        return
      else if (DBBC.eq.rack.and.
     &       (DBBC_DDC.eq.rack_type.or.DBBC_DDC_FILA10G.eq.rack_type)
     &       ) then
        call fc_tpput_dbbc(ip,itpis_dbbc,isub,ibuf,nch,ilen)
        return
      else if (DBBC.eq.rack.and.
     &       (DBBC_PFB.eq.rack_type.or.DBBC_PFB_FILA10G.eq.rack_type)
     &       ) then
        call fc_tpput_dbbc_pfb(ip,itpis_dbbc_pfb,isub,ibuf,nch,ilen)
        return
      else if (DBBC3.eq.rack) then
        call fc_tpput_dbbc3(ip,itpis_dbbc3,isub,ibuf,nch,ilen)
        return
      else
        call fc_tpput_norack(ip,itpis_norack,isub,ibuf,nch,ilen)
        return
      endif
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      nrec = 1
C
990   ip(1) = iclass
      ip(2) = nrec
      ip(3) = ierr
      call char2hol('qk',ip(4),1,2)
      return
      end
