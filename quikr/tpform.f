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
      subroutine tpform(ip,itask)
C  specify tape format c#870115:04:35#
C 
C   TPFORM reads the a priori head offsets for each tape pass number
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - class (called ICLASS internally)
C        IP(2) - # rec
C        IP(3) - error
C        IP(4) - who we are 
C 
C   LOCAL CONSTANTS
      parameter (maxpass = 200)              ! maximum head pass number
      parameter (maxoff = 4000)              ! maximum head offset
      parameter (minoff = -4000)             ! minimum head offset
      parameter (ilen = 80)                  ! size of local class buffer
C
C   COMMON BLOCKS USED
      include '../include/fscom.i'
C       contains array ITAPOF
C
C     CALLED SUBROUTINES: GTPRM
C
C   LOCAL VARIABLES
C        NCHAR  - number of characters in buffer
C        ICH    - character counter
      integer*2 ibuf(40)            !  class buffer
      logical passno
C               - keeps track of whether parameter is a pass # or head offset
      dimension iparm(2)      !  parameters returned from gtprm
      dimension ireg(2)             !  registers from exec calls
      integer get_buf
      dimension ipass(20),ioffset(20)
C               - paired pass numbers and head offsets
      equivalence (reg,ireg(1)),(parm,iparm(1)) 
C 
C 
C  PROGRAMMER: LAR     LAST MODIFIED: <910329.1842>
C 
C     1. Set output parameters (except error flag) and read from input
C     class into local buffer IBUF.
C 
      if( itask.eq.1) then
         indxtp=1
      else
         indxtp=2
      endif
c
      iclcm = ip(1) 
      iclass = 0
      ip(1)=iclass
      ip(2)=0
      call char2hol('q^',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3) = -1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
C           Scan for "="; its absence indicates a request to see
C             the contents of the ITAPOF array.
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) then
        nchar = 1
        nrec = 0
        do i=1,maxpass
          if (itapof(i,indxtp).ge.minoff .and.
     $          itapof(i,indxtp).le.maxoff) then
            nchar = ichmv_ch(ibuf,nchar,'  ')
            nchar = nchar + ib2as(i,ibuf,nchar,o'100003')
            nchar = ichmv_ch(ibuf,nchar,'->')
            nchar = nchar + ib2as(itapof(i,indxtp),ibuf,nchar,o'100005')
            if (nchar.gt.58) then
              call put_buf(iclass,ibuf,1-nchar,'fs','  ')
              nchar = 1
              nrec = nrec + 1
            endif
          endif
        enddo
        if (nchar.gt.1) then
          call put_buf(iclass,ibuf,1-nchar,'fs','  ')
          nrec = nrec + 1
        endif
        ip(1)=iclass
        ip(2)=nrec
        ip(3)=0
        return
      endif
C 
C     2. Step through buffer getting each parameter and decoding it.
C     Command from user has these parameters: 
C           TAPEFORM=<pass>,<offset>,<pass>,<offset>, ...
C 
      ich = 1+ieq
      do n=1,40
        m=(n+1)/2
        passno = (m+m.ne.n)
        call gtprm(ibuf,ich,nchar,1,parm,ierr)
        if (iparm(1).lt.minoff .or. iparm(1).gt.maxoff .or.  (passno
     ^     .and. (iparm(1).gt.maxpass .or. iparm(1).le.0) ) ) then
          ip(3) = -201
          return
        endif
        if (passno) then
          ipass(m)=iparm(1)
        else
          ioffset(m)=iparm(1)
        endif
        if (ich.gt.nchar) then             ! last parameter
          if (passno) then                     ! abnormal end; error
            ip(3) = -3
          else                                 ! normal end of list
            do i=1,m
              itapof(ipass(i),indxtp) = ioffset(i)
            enddo
            ip(3) = 0
          endif
          return
        endif
      enddo               
      ip(3) = -42          ! get here only if line is unusually long
      return
      end 
