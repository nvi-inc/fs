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
      SUBROUTINE vunppcal(modef,stdef,ivexnum,iret,ierr,lu,
     .cpcalref,ipct,ntones,npcaldefs,kfirst_call)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C     VUNPPCAL gets the PHASE_CAL_DETECT def statements
C     for station STDEF and mode MODEF.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 971208 nrv New. Copied from vunpif.
C
C  INPUT:
      character*128 stdef ! station def to get
      character*128 modef ! mode def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
      logical kfirst_call     !first call to this routine? Allows initialization.
C
C  OUTPUT:
      integer iret ! error return from vex routines, !=0 is error
      integer ierr ! error from this routine, >0 indicates the
C                    statement to which the VEX error refers,
C                    <0 indicates invalid value for a field
      character*6 cpcalref(max_chan) ! pcal refs
      integer ipct(max_chan,max_tone) ! list of tones
      integer ntones(max_chan) ! number of tones in ipct
      integer npcaldefs ! number of pcal found
C
C  LOCAL:
      character*128 cout
      integer i,ip,nch,it,j
      integer fvex_int,fvex_len,fvex_field,ptr_ch,fget_all_lowl
      logical kwarning_large_tone_number

      if(kfirst_call) then
         kfirst_call=.false.
         kwarning_large_tone_number=.false.
      endif
C
C  Initialize
      npcaldefs=0
      do ip=1,max_chan
        cpcalref(ip)=''
        ntones(ip)=0
        do it=1,max_tone
          ipct(ip,it)=0
        enddo
      enddo
C
C  1. PHASE_CAL_DETECT def statements
C
      ierr = 1
      iret = fget_all_lowl(ptr_ch(stdef),ptr_ch(modef),
     .ptr_ch('phase_cal_detect'//char(0)),
     .ptr_ch('PHASE_CAL_DETECT'//char(0)),ivexnum)
      ip=0
      do while (ip.lt.max_chan.and.iret.eq.0) ! get all pcal defs
        ip=ip+1

C  1.1 IF def
        ierr = 11
        iret = fvex_field(1,ptr_ch(cout),len(cout)) ! get pcal ref
        if (iret.ne.0) return
        nch = fvex_len(cout)
        if (nch.gt.len(cpcalref(ip)).or.nch.le.0) then
          ierr=-1
          write(lu,'("VUNPPCAL01 - PCAL ref too long")')
        else
          cpcalref(ip)=cout(1:nch)
        endif

C  1.2 List of tones

        ierr = 12
        i=2 ! fields 2 and up may be tones
        iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get tone
        do while (i.le.max_tone+1.and.iret.eq.0) ! get tones
          if (iret.eq.0) then ! a tone
            iret = fvex_int(ptr_ch(cout),j) ! convert to binary
            if (j.lt.0.or.j.gt.max_tone) then
              if(.not.kwarning_large_tone_number) then
                 kwarning_large_tone_number=.true.
                 write(lu,'(a)')
     >             'VUNPPCAL01: Warning! All phase tones greater'//
     >              ' than 16 ignored at all stations'
               endif
            else
              ipct(ip,i-1)=j
            endif
          endif ! a tone
          i=i+1
          iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get next tone
        enddo ! get tones
        ntones(ip) = i-2
C       Now check whether there are more tones than allowed.
        if (iret.eq.0)
     .  write(lu,'("VUNPPCAL02 - Too many tones, max is ",i3)') max_tone

C       Get next pcal def statement
        iret = fget_all_lowl(ptr_ch(stdef),
     .  ptr_ch(modef),ptr_ch('phase_cal_detect'//char(0)),
     .  ptr_ch('PHASE_CAL_DETECT'//char(0)),0)
      enddo ! get all pcal defs

      iret=0
      npcaldefs = ip

      if (iret.eq.0.and.ierr.gt.0) ierr=0
      return
      end
