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
      subroutine lxhms(xx,line,nch)
C 
C LXHMS - Convert log time from double precision to ASCII.
C 
C MODIFICATIONS:
C 
C    DATE     WHO  DESCRIPTION
C    820917   KNM  SUBROUTINE CREATED 
C 
C INPUT VARIABLES:
C 
      double precision xx 
C        - Contains the log time
C 
C OUTPUT VARIABLES: 
C 
      integer*2 line(1) 
C        - Plotting output array
C     NCH - Character count 
C 
C COMMON BLOCKS USED: 
C 
      include 'lxcom.i'
C 
C SUBROUTINE INTERFACES:
C 
C     CALLING SUBROUTINES:
C 
C     LXPLT - Plotting routine
C 
C LOCAL VARIABLES:
C 
C     LXDAY,LXHR,LXMIN,LXSEC - Day, Hours, Minutes, & Seconds 
C     TIME - Contains log time
      integer it(6)
      integer*4 secs
C 
C INITIALIZED VARIABLES:
C 
C 
C ******************************************************************* 
C 
C Convert the double precision variable TIME ( which is the log day & 
C fraction of a day to log day, hours, minutes, & seconds.
C 
C ******************************************************************* 
C 
C 
      secs=int(xx/100.0d0+0.005d0)
      call fc_secs2rte(secs,it)
      it(1)=(xx-secs*100.0d0)+.5
      nch=nch+ib2as(it(6),line,nch,4)
      nch=ichmv_ch(line,nch,'.')
      nch=nch+ib2as(it(5),line,nch,o'40000'+o'400'*2+3) 
      nch=ichmv_ch(line,nch,'.')
      nch=nch+ib2as(it(4),line,nch,o'40000'+o'400'+2) 
      nch=ichmv_ch(line,nch,':')
      nch=nch+ib2as(it(3),line,nch,o'40000'+o'400'+2)
      nch=ichmv_ch(line,nch,':')
      nch=nch+ib2as(it(2),line,nch,o'40000'+o'400'+2)
      nch=ichmv_ch(line,nch,'.')
      nch=nch+ib2as(it(1),line,nch,o'40000'+o'400'+2)

C
      return
      end 
