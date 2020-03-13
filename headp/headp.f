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
      program headp
C
C  HEADP WRITES THE RESULT OF THE LAST HDCALC AND WORM COMMANDS
C  TO FILE /CONTROL/HEAD.NEW
C
      character*1 hd(2)
      character*3 slow
      character*4 type(0:2)
      character*8 posit
      character*20 tbuff
      character*63 name
      character*80 prog
      logical kspd,kcal,kexist,k2heads
      integer it(6),trimlen,nch
C
      include '../include/fscom.i'
C
      data type/' all',' odd','even'/,hd/'1','2'/
C
      call setup_fscom
      call read_fscom
      call fs_get_drive(drive)
      call fs_get_drive_type(drive_type)
c
      prog=' '
      call rcpar(0,prog)
      nch=trimlen(prog)
      itp=0
      if(nch.gt.5) then
         if(prog(nch-5:nch).eq.'headp1') then
            itp=1
         else if(prog(nch-5:nch).eq.'headp2') then
            itp=2
         endif
      endif
      if(nch.gt.4) then
         if(prog(nch-4:nch).eq.'headp') then
            if(drive(1).ne.0.and.drive(2).eq.0) then
               itp=1
            else if(drive(1).eq.0.and.drive(2).ne.0) then
               itp=2
            else
               itp=-1
            endif
         endif
      endif
c
      if(itp.eq.1.and.drive(1).eq.0) then
         write(6,*)
     $        'recorder 1 not in use'
         goto 99999
      else if(itp.eq.2.and.drive(2).eq.0) then
         write(6,*)
     $        'recorder 2 not in use'
         goto 99999
      else if(itp.eq.0) then
         write(6,*)
     $        'incorrect command name, must end in headp1 or headp2'
         goto 99999
      else if(itp.eq.-1) then
         write(6,*)
     $        'more than one recorder or no recorder active'
         goto 99999
      endif
c
      name=' '
      call rcpar(1,name)
      k2heads=MK3.eq.drive(itp).or.VLBA4.eq.drive(itp).or.
     $       (MK4.eq.drive(itp).and.MK4B.ne.drive_type(itp)).or.
     $       (VLBA.eq.drive(itp).and.VLBAB.eq.drive_type(itp))
C
      kcal=kswrite_fs(itp).and.kbdwrite_fs(itp).and.ksdwrite_fs(itp)
      if(k2heads) then
         kcal=kcal.and.ksread_fs(itp).and.ksdread_fs(itp).and.
     $        kbdread_fs(itp)
      endif
      if(.not.kcal) write(6,*)
     &  'drive ',hd(itp),
     $     ' head calibration has not been completed successfully.'
C
      kspd=kwrwo_fs(itp)
      if(k2heads) then
         kspd=kspd.and.krdwo_fs(itp)
       endif
      if(.not.kspd.and..not.(
     & (drive(itp).eq.VLBA.and.VLBA2.eq.drive_type(itp)).or.
     &      (drive(itp).eq.VLBA4.and.VLBA42.eq.drive_type(itp)) ))
     & write(6,*)
     &  'drive ',hd(itp),
     $      ' inch worm speeds have not been successfully calibrated.'
C
      if((.not.kcal).or.
     &     (.not.kspd.and..not.(
     &     (drive(itp).eq.VLBA.and.VLBA2.eq.drive_type(itp)).or.
     &     (drive(itp).eq.VLBA4.and.VLBA42.eq.drive_type(itp))
     &     ))) then
        write(6,*) 'no output file generated.'
        goto 99999
      endif
C
      if(name.eq.' ') then
         if(itp.eq.1) then
            name=FS_ROOT//'/control/head1.new'
         else
            name=FS_ROOT//'/control/head2.new'
         endif
      endif
      inquire(file=name,exist=kexist,err=99)
      if(kexist) then
        write(6,'(1x,a,a)')  name(:max(1,trimlen(name))),
     &    ' already exists, it will not be overwritten.'
        goto 99999
      endif

      ierr = 0
      call fopen(16,name,ierr)
      if (ierr.ne.0) goto 99
C
33    continue
      call fc_rte_time(it,it(6))
      write(tbuff,90101) it(6),it(5),it(4),it(3),it(2),it(1)
90101 format(i4,'/',i3,'.',i2,':',i2,':',i2,'.',i2)
      do i=1,len(tbuff)
        if(tbuff(i:i).eq.' ') tbuff(i:i)='0'
      enddo
C
      write(16,9010) hd(itp)
      write(16,9020)
      write(16,9025) tbuff
      write(16,9020)
      write(16,9026)
      call fs_get_lnaant(lnaant)
      write(16,9027) tbuff(1:8),lnaant
      write(16,9020)
      write(16,9030)
      call fs_get_wrhd_fs(wrhd_fs,itp)
      call fs_get_rdhd_fs(rdhd_fs,itp)
      write(16,9040) type(wrhd_fs(itp)),
     $     type(rdhd_fs(itp)),type(rpro_fs(itp)),type(rpdt_fs(itp))
      write(16,9020)
      if(kadapt_fs(itp)) then
        posit='adaptive'
      else
        posit='fixed  '
      endif
      if(kiwslw_fs(itp)) then
        slow='yes'
      else
        slow='no'
      endif
      if(.not.(
     $     (drive(itp).eq.VLBA.and.VLBA2.eq.drive_type(itp)).or.
     $     (drive(itp).eq.VLBA4.and.VLBA42.eq.drive_type(itp))
     $     )) then
         write(16,9044)
      else
         write(16,9144)
      endif
      write(16,9045) posit,slow,lvbosc_fs(itp),ilvtl_fs(itp)
      write(16,9020)
C
      write(16,9050)
      if((drive(itp).eq.VLBA.and.VLBA2.eq.drive_type(itp)).or.
     &     (drive(itp).eq.VLBA4.and.VLBA42.eq.drive_type(itp))
     &     ) then
        write(16,9060) 0.0,0.0
        write(16,9070) 0.0,0.0
      else if(k2heads) then
        write(16,9060) fowo_fs(1,itp),fowo_fs(2,itp)
        write(16,9070) sowo_fs(1,itp),sowo_fs(2,itp)
      else
        write(16,9060) fowo_fs(1,itp),0.0
        write(16,9070) sowo_fs(1,itp),0.0
      endif
C
      write(16,9020)
      if(k2heads) then
        write(16,9080) rbdwrite_fs(itp),rbdread_fs(itp)
      else
        write(16,9080) rbdread_fs(itp),0.0
      endif
C
      write(16,9020)
      if((drive(itp).eq.VLBA.and.VLBA2.eq.drive_type(itp)).or.
     &     (drive(itp).eq.VLBA4.and.VLBA42.eq.drive_type(itp))
     &     ) then
        write(16,9090) 0.0,0.0
        write(16,9100) 0.0,0.0
      else if(k2heads) then
        write(16,9090) fiwo_fs(1,itp),fiwo_fs(2,itp)
        write(16,9100) siwo_fs(1,itp),siwo_fs(2,itp)
      else
        write(16,9090) fiwo_fs(1,itp),0.0
        write(16,9100) siwo_fs(1,itp),0.0
      endif
C
      write(16,9020)
      if(k2heads) then
        write(16,9110) rsdwrite_fs(itp),rsdread_fs(itp)
      else
        write(16,9110) rsdread_fs(itp),0.0
      endif
C
      write(16,9020)
      if(k2heads) then
        write(16,9120) rswrite_fs(itp),rsread_fs(itp)
        write(16,9130) rswrite_fs(itp),rsread_fs(itp)
      else if(.not.(
     &       (drive(itp).eq.VLBA.and.drive_type(itp).eq.VLBA2).or.
     &       (drive(itp).eq.VLBA4.and.drive_type(itp).eq.VLBA42)
     &       )) then
        write(16,9120) rsread_fs(itp),0.0
        write(16,9130) rsread_fs(itp),0.0
      else
        write(16,9121) rsread_fs(itp),0.0
        write(16,9131) rsread_fs(itp),0.0
      endif
C
      write(6,'(1x,a)') 'output in file: '//name(:max(1,trimlen(name)))
      close(6)
      goto 99999
C
99    continue
      write(6,991) ierr,name(:max(1,trimlen(name)))
991   format(' error ',i6,' creating ',a,'.')
      goto 99999
C
9010  format("* /control/head",a1,".ctl - head parameter control file")
9020  format("*")
9025  format("* history:                 last edited: <",a,">")
9026  format("* who  when   what")
9027  format("* xxx  ",a," created at ",4a2)
9030  format(
     & "* write heads  read heads  reproduce: electronics  detector")
9040  format(5x,a4,8x,a4,20x,a4,8x,a4)
9044  format("*  positioning  slow  osc (mhz)  a/d tol. (counts)")
9144  format("*  positioning  slow  osc (mhz)  a/d tol. (microns)")
9045  format(5x,a8,4x,a3,1x,f8.4,2x,i6)
9050  format("* write    read")
9060  format(2(f7.1,1x),"  fast out inchworm speed (microns/sec)")
9070  format(2(f7.1,1x),"  slow out inchworm speed (microns/sec)")
9080  format(2(f7.1,1x),"  absolute head offset    (microns)")
9090  format(2(f7.1,1x),"  fast in  inchworm speed (microns/sec)")
9100  format(2(f7.1,1x),"  slow in  inchworm speed (microns/sec)")
9110  format(2(f7.1,1x),
     & "  (reverse)-(forward) relative offset (microns)")
9120  format(2f8.2,     "  positive voltage scale (microns/volt)")
9121  format(2f8.5,     "  positive voltage scale (microns/kA)")
9130  format(2f8.2,     "  negative voltage scale (microns/volt)")
9131  format(2f8.5,     "  negative voltage scale (microns/kA)")
C
99999 continue
      end
