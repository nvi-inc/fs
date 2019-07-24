      program headp
C
C  HEADP WRITES THE RESULT OF THE LAST HDCALC AND WORM COMMANDS
C  TO FILE /CONTROL/HEAD.NEW
C
      character*3 slow
      character*4 type(0:2)
      character*6 inttodecimal
      character*8 posit
      character*20 tbuff
      character*63 name
      logical kspd,kcal,kexist
      integer it(6),trimlen
      integer*4 totalseconds,seconds
C
      include '../include/fscom.i'
C
      data type/' all',' odd','even'/
C
      call setup_fscom
      call read_fscom
      call fs_get_drive(drive)
c
      name=' '
      call rcpar(1,name)
C
      kcal=kswrite_fs.and.kbdwrite_fs.and.ksdwrite_fs
      if(VLBA.ne.iand(drive,VLBA)) then
         kcal=kcal.and.ksread_fs.and.ksdread_fs.and.kbdread_fs
      endif
      if(.not.kcal) write(16,*)
     &  'head calibration has not been completed successfully.'
C
      kspd=kwrwo_fs
      if(VLBA.ne.iand(drive,VLBA)) then
         kspd=kspd.and.krdwo_fs
       endif
      if(.not.kspd) write(16,*)
     &  'inch worm speeds have not been successfully calibrated.'
C
      if((.not.kcal).or.(.not.kspd)) then
        write(16,*) 'no output file generated.'
        goto 99999
      endif
C
      if(name.eq.' ') name=FS_ROOT//'/control/head.new'
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
      write(16,9010)
      write(16,9020)
      write(16,9025) tbuff
      write(16,9020)
      write(16,9026)
      call fs_get_lnaant(lnaant)
      write(16,9027) tbuff(1:8),lnaant
      write(16,9020)
      write(16,9030)
      write(16,9040)
     &        type(wrhd_fs),type(rdhd_fs),type(rpro_fs),type(rpdt_fs)
      write(16,9020)
      if(kadapt_fs) then
        posit='adaptive'
      else
        posit='fixed  '
      endif
      if(kiwslw_fs) then
        slow='yes'
      else
        slow='no'
      endif
      write(16,9044)
      write(16,9045) posit,slow,lvbosc_fs,ilvtl_fs
      write(16,9020)
C
      write(16,9050)
      if(VLBA.ne.iand(drive,VLBA)) then
        write(16,9060) fowo_fs
        write(16,9070) sowo_fs
      else
        write(16,9060) fowo_fs(1),0.0
        write(16,9070) sowo_fs(1),0.0
      endif
C
      write(16,9020)
      if(VLBA.ne.iand(drive,VLBA)) then
        write(16,9080) rbdwrite_fs,rbdread_fs
      else
        write(16,9080) rbdread_fs,0.0
      endif
C
      write(16,9020)
      if(VLBA.ne.iand(drive,VLBA)) then
        write(16,9090) fiwo_fs
        write(16,9100) siwo_fs
      else
        write(16,9090) fiwo_fs(1),0.0
        write(16,9100) siwo_fs(1),0.0
      endif
C
      write(16,9020)
      if(VLBA.ne.iand(drive,VLBA)) then
        write(16,9110) rsdwrite_fs,rsdread_fs
      else
        write(16,9110) rsdread_fs,0.0
      endif
C
      write(16,9020)
      if(VLBA.ne.iand(drive,VLBA)) then
        write(16,9120) rswrite_fs,rsread_fs
        write(16,9130) rswrite_fs,rsread_fs
      else
        write(16,9120) rsread_fs,0.0
        write(16,9130) rsread_fs,0.0
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
9010  format("* /control/head.ctl - head parameter control file")
9020  format("*")
9025  format("* history:                 last edited: <",a,">")
9026  format("* who  when   what")
9027  format("* xxx  ",a," created at ",4a2)
9030  format(
     & "* write heads  read heads  reproduce: electronics  detector")
9040  format(5x,a4,8x,a4,20x,a4,8x,a4)
9044  format("*  positioning  slow  osc (mhz)  a/d tol. (counts)")
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
9130  format(2f8.2,     "  negative voltage scale (microns/volt)")
C
99999 continue
      end
