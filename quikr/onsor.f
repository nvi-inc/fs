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
      subroutine onsor(ip)
C  onsource check c#870115:04:43# 
C 
C     Display on-source information 
C 
C   MODIFIED 850204 TO HANDLE ERROR RETURN FROM ANTCN 
      include '../include/fscom.i'
C 
      dimension ip(1) 
      dimension ireg(2),iparm(2)
      integer get_buf
      integer*2 ibuf(20),ion(6),iof(6)
      integer it(6)
      integer*4 ihsecs,ihsecs2,ihsecsday
      logical kbreak
C 
      equivalence (ireg(1),reg),(iparm(1),parm) 
C 
      data ilen/40/,ihsecsday/8640000/
C 
      iclcm = ip(1) 
      if (iclcm.eq.0) then
        ierr = -1 
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      ito=0
      call char2hol(' ', ion,1,12)
      call char2hol(' ', iof,1,12)
      if (ieq.ne.0) then
         ich=ieq+1
         ic1=ich
         call gtprm2(ibuf,ich,nchar,0,parm,ierr)
         if(ierr.eq.0) then
            ito=ias2b(ibuf,ic1,ich-ic1-1)
            if(ito.lt.0.or.ito.gt.86400) then
              ierr=-11
              goto 990
           endif
           ito=ito*100
        endif
        ic1=ich
        call gtprm2(ibuf,ich,nchar,0,parm,ierr)
        call gtfld(ibuf,ic1,ich-2,ics,ice)
        if(ierr.eq.0) then
           if(ice-ics+1.le.12) then
              idum=ichmv(ion,1,ibuf,ics,ice-ics+1)
           else
              ierr=-12
              goto 990
           endif
        endif
        ic1=ich
        call gtprm2(ibuf,ich,nchar,0,parm,ierr)
        call gtfld(ibuf,ic1,ich-2,ics,ice)
        if(ierr.eq.0) then
           if(ice-ics+1.le.12) then
              idum=ichmv(iof,1,ibuf,ics,ice-ics+1)
           else
              ierr=-13
              goto 990
           endif
        endif
      endif
c      write(6,'(i6,1x,6a2,1a,6a2)')ito,(ion(iw),iw=1,6),(iof(iw),iw=1,6)
C 
C     2. The command is: ONSOURCE 
C     The response may be either TRACKING or SLEWING, 
C     depending on the variable IONSOR=1 or 0.
C     Schedule ANTCN to get the az,el errors and set IONSOR.
C 
      call fs_get_idevant(idevant)
      if (ichcm_ch(idevant,1,'/dev/null ').ne.0) then
         call fc_rte_time(it,it(6))
c gymnastiscs to make sure int4 arithmatic
         ihsecs=it(3)+60*it(4)
         ihsecs=it(1)+100*(it(2)+60*ihsecs)
c         write(6,*) 'ihsecs ',ihsecs
         imode=3
         if(ito.ne.0) imode=5
 100     continue
         call run_prog('antcn','wait',imode,idum,idum,idum,idum)
         call rmpar(ip)
         call run_prog('flagr','nowait',0,0,0,0,0)
         call fs_get_ionsor(ionsor)
         if(ito.gt.0.and.ionsor.eq.0) then
            call fc_rte_time(it,it(6))
c gymnastiscs to make sure int4 arithmatic
            ihsecs2=it(3)+60*it(4)
            ihsecs2=it(1)+100*(it(2)+60*ihsecs2)
c            write(6,*) 'ihsecs2 ',ihsecs2,' ito ', ihsecs+ito 
            if(ihsecs2.lt.ihsecs) ihsecs2=ihsecs2+ihsecsday
            if(ihsecs+ito.gt.ihsecs2) then
               if(kbreak('quikr')) then
                  ierr=-300
                  goto 990
               endif
               call susp(2,1)
               goto 100
            endif
         endif
      else
        ierr= -302
        goto 990
      endif

      ierr = ip(3)
      if (ierr.lt.0)  return
      call fs_get_ionsor(ionsor)
      if (ionsor.eq.0) ierr = -301
C 
      if(ieq.eq.0) ieq=nchar+1
      nch = ichmv_ch(ibuf,ieq,'/')
C                   Move in the response indicator
      nch = isoed(-1,ionsor,ibuf,nch,ilen)
C                   Encode the response word TRACKING or SLEWING
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qo',ip(4),1,2)
      if(ionsor.eq.0.and.0.ne.ichcm_ch(iof,1,'            ')) then
         call copin(iof,iflch(iof,12))
      else if(ionsor.ne.0.and.0.ne.ichcm_ch(ion,1,'            ')) then
         call copin(ion,iflch(ion,12))
      endif
      return
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qo',ip(4),1,2)
      return
      end 
