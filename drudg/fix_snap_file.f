      subroutine fix_snap_file(lfile)
! Subroutine to fix the scan name in the snap file.
! Scan names will have the time until the next "et" or "disk_record_off" appended.
!
!  2004Apr05   JMGipson  First version
!  2007Jul20   JMGipson  Now searches for disk_record_on. Used to search for data_valid
!  2007Dec10   JMGipson. Changed back to Data_valid=on.
!                        Disk_record=on failed if you didn't stop recording.
!  2007Dec11   JMGipson. Modified so that will handle the case when scans aren't recording.
!                        Also, uses earliest of disk_Record=on or  data_valid

      implicit none
      character*(*) lfile

! Functions
      integer trimlen
      integer itimedifsec

! local
      integer lu_in,lu_out
      character*256 ltmpfil
      integer MaxScan
      parameter (MaxScan=5000)
      integer itime_scan(5,MaxScan)
      integer idur(MaxScan)
      integer itime_now(5)
      logical kvalidtime
      character*256 ldum

      integer iscan_start    !first scan when tape starts moving.
      integer num_scan       !number of scans.
      integer iscan

      integer i1,i2,i
      integer j

! used to hold the input line.
      character*132 ctmp

      logical kdebug

      kdebug=.false.
!      kdebug=.true.
! 1. Read in the file.
      lu_in=9
      lu_out=8
      open(lu_in,file=lfile)

      num_scan=0
100   continue
      read(lu_in,'(a132)',end=200) ctmp
      call capitalize(ctmp)

      if(ctmp(1:1) .eq. '"') then
        goto 100
      else if(ctmp(1:9) .eq. "SCAN_NAME") then
        num_scan=num_scan+1
        idur(num_scan)=0
      else if(ctmp(1:1) .eq. "!") then
        call snap_ReadTime(ctmp,itime_now,kvalidtime)
        if(.not. kvalidtime) then
           goto 100
        endif
      else if(ctmp(1:14).eq. "DISK_RECORD=ON") then
        iscan_start=num_scan
        do i=1,5
          itime_scan(i,num_scan)=itime_now(i)
        end do
        if(kdebug) then
          write(*,'("REC_ON     ",i4,".",i3,".",2(i2.2,"."),i2.2)')
     >        (itime_now(j),j=1,5)
        endif
      else if(ctmp(1:14).eq. "DATA_VALID=ON") then
        if(num_scan .ne.  iscan_start) then
          do i=1,5
            itime_scan(i,num_scan)=itime_now(i)
          end do
        endif
        if(kdebug) then
          write(*,'("DATA_VALID ",i4,".",i3,".",2(i2.2,"."),i2.2)')
     >        (itime_now(j),j=1,5)
        endif
! See if tape has started moving.
      else if(ctmp(1:10) .eq. 'DISK_END' .or.
     >        ctmp(1:10) .eq. 'DISC_END' .or.
     >        ctmp(1:15) .eq. 'DISK_RECORD=OFF') then

        if(kdebug) then
          write(*,'("OFF        ",i4,".",i3,".",2(i2.2,"."),i2.2)')
     >        (itime_now(j),j=1,5)
        endif

        do iscan=iscan_start,num_scan
          idur(iscan)=itimedifsec(itime_now,itime_scan(1,iscan))
          if(kdebug) then
            write(*,'(i4,".",i3,".",2(i2.2,"."),i2.2,2x,2i4)')
     >        (itime_scan(j,iscan),j=1,5),iscan,idur(iscan)
          endif
        end do
      endif
      goto 100

200   continue

! now read through the file once again, appending the total recording time
! at the end of every scan name.
      rewind(lu_in)
      i=trimlen(lfile)
      ltmpfil=lfile(1:i)//".tmp"
      open(lu_out,file=ltmpfil)

      iscan=0
300   continue
      read(lu_in,'(a132)',end=400) ctmp
      i=trimlen(ctmp)+1
      if(ctmp(1:9) .eq."scan_name") then
        iscan=iscan+1
        write(ctmp(i:132),'(",",i6)') idur(iscan)
        call squeezewrite(lu_out,ctmp)       !get rid of spaces, and write it out.
      else
        write(lu_out,'(a)') ctmp(1:i)
      endif
      goto 300

400   continue
      close(lu_in)
      close(lu_out)

      i1=trimlen(ltmpfil)
      i2=trimlen(lfile)
      write(ldum,*) "mv ",ltmpfil(1:i1+1),lfile(1:i2)
      i1=trimlen(ldum)
      i1=i1+1
      ldum(i1+1:i1+1)=char(0)
      
      call system(ldum(1:i1))
      return
      end
