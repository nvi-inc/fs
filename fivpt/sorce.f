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
      subroutine sorce(rut,idoy,iyr,lbuf,isbuf) 
      integer*2 lbuf(1) 
C 
C WRITE SOURCE LOG ENTRY
C 
      include '../include/fscom.i'
C 
C  WE READ THE FOLLOWING FROM FSCOM:
C 
C    LSORNA,  DEC50, RA50, EP1950,
C 
C  SOURCE ENTRY IDENTIFIER
C 
      icnext=1
      icnext=ichmv_ch(lbuf,icnext,'source ')
C 
C  SOURCE NAME
C 
      call fs_get_lsorna(lsorna)
      icnext=ichmv(lbuf,icnext,lsorna,1,10) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C RA
C 
      call fs_get_ra50(ra50)
      icnext=iptra(ra50,lbuf,icnext)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C DECLINATION 
C 
      call fs_get_dec50(dec50)
      icnext=iptdc(dec50,lbuf,icnext) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C EPOCH 
C 
      call fs_get_ep1950(ep1950)
      icnext=icnext+jr2as(ep1950,lbuf,icnext,-6,1,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C  TIME 
C 
      ih=int(rut/3600.0)
      rut1=rut-3600.0*float(ih) 
      im=int(rut1/60.0) 
      rut2=rut1-60.0*float(im)
      is=int(rut2+0.5)
C 
c not Y10K compliant
      icnext=icnext+ib2as(iyr,lbuf,icnext,o'40000'+o'400'*4+4) 
      icnext=ichmv_ch(lbuf,icnext,'.') 
      icnext=icnext+ib2as(idoy,lbuf,icnext,o'40000'+o'400'*3+3) 
      icnext=ichmv_ch(lbuf,icnext,'.') 
      icnext=icnext+ib2as(ih,lbuf,icnext,o'40000'+o'400'*2+2) 
      icnext=ichmv_ch(lbuf,icnext,':') 
      icnext=icnext+ib2as(im,lbuf,icnext,o'40000'+o'400'*2+2) 
      icnext=ichmv_ch(lbuf,icnext,':') 
      icnext=icnext+ib2as(is,lbuf,icnext,o'40000'+o'400'*2+2) 
      icnext=ichmv_ch(lbuf,icnext,' ')
C 
C EVEN OFF THE LAST WORD AND SEND IT
C 
      nchar=icnext-1
      if(1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ') 
      call logit2(lbuf,nchar)
C 
      return
      end 
