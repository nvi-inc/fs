*
* Copyright (c) 2020 NVI, Inc.
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
      subroutine proc_lo(ix,icode,clo)
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
!      include 'bbc_freq.ftni'
! make and write out the lo command.
! on entry        
      integer icode 
      character*(*) clo
      
      integer ix	     !lo index
! functions
! functions
      integer ichmv_ch  !lnfch  
      integer ir2as
      integer mcoma
      integer ichmv
      real rpc 

! Local
      integer nch
               
      write(cbuf,'("lo=lo",a,",",f9.2,",",a1,"sb,")') 
     >         clo, freqlo(ix,istn,icode), cosb(ix,istn,icode)(1:1)
!              write(*,*) cbuf(1:25)
      call squeezeleft(cbuf,nch)  
      nch=nch+1            
      if (kvex) then ! have pol and pcal
        nch=ichmv(ibuf,nch,lpol(ix,istn,icode),1,1) ! polarization
        nch=ichmv_ch(ibuf,nch,'cp,')
        rpc = freqpcal(ix,istn,icode) ! pcal spacing
        if (rpc.gt.0.0) then ! value
          nch=nch+ir2as(rpc,ibuf,nch,5,3)
        else ! off
           nch=ichmv_ch(ibuf,nch,'off')
        endif ! value/off
        rpc = freqpcal_base(ix,istn,icode) ! pcal offset
        if (rpc.gt.0.0) then
          NCH = MCOMA(IBUF,NCH)
          nch=nch+ir2as(rpc,ibuf,nch,5,3)
        endif
      else if(kgeo) then
         nch=ichmv_ch(ibuf,nch,"rcp,1")
      endif ! have pol and pcal          
      call lowercase_and_write(lu_outfile,cbuf)
      return
      end 
