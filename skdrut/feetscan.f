
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
      integer function feetscan(ibuf,nch,ipas,ifeet,idrive,istn,icod)
      implicit none

C  FEETSCAN converts the footage and pass number and
C  puts them into the scan buffer.

C History
C 970722 nrv New. Removed form newscan and addscan.
C 001101 nrv Put footage field at nch+1 for S2 (as for non-S2).

C Common blocks
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'

C Input and Output
      integer*2 ibuf(*)
      integer nch ! character to start with, updated
      integer istn,icod
      integer ipas,ifeet,idrive

C Local
      integer i,nchx
      logical kfor
      character*1 cdir
      integer*2 ibufx(4)
      character*1 pnum ! function
      integer ib2as,ichmv_ch,ichmv

C  Insert the pass number in the scan, then determine
C  whether this is a forward or reverse pass by the
C  evenness or oddness of the pass number.
C  If it's a non-recording scan, set the pass to '0'.

     
      
      NCH = ICHMV_ch(IBUF,NCH+1,"1F")         
C  Put in footage. For S2 this is in seconds.
C  Max length is 5 characters, as set up in newscan.
      nchx=ib2as(ifeet,ibufx,1,5+o'40000'+o'400'*5)
      nch=ichmv(ibuf,nch,ibufx,1,5)
      feetscan=nch

      return
      end
