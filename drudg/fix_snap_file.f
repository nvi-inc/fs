      subroutine fix_snap_file(lfile)
! Subroutine to fix the scan name in the snap file.
! Scan names will have the time until the next "et" or "disk_record_off" appended.
!
!  V1.00    JMGipson  2004Apr05

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
      logical kfirst
      character*256 ldum

      integer iscan_start    !first scan when tape starts moving.
      integer iscan_last
      integer iscan

      integer i1,i2,i

! used to hold the input line.
      character*132 ctmp

! 1. Read in the file.
      lu_in=9
      lu_out=8
      open(lu_in,file=lfile)

      kfirst=.true.
      iscan_last=0
100   continue
      read(lu_in,'(a132)',end=200) ctmp
      call capitalize(ctmp)

      if(ctmp(1:1) .eq. '"') then
        goto 100
      else if(ctmp(1:1) .eq. "!") then
        call snap_ReadTime(ctmp,itime_now,kvalidtime)
        if(.not. kvalidtime) then
           goto 100
        endif
      else if( index(ctmp(1:11),'"DATA START').ne.0.or.
     >         index(ctmp(1:13),'DATA_VALID=ON').ne.0.or.
     >         index(ctmp(1:14),'DATA_VALID1=ON').ne.0.or.
     >         index(ctmp(1:14),'DATA_VALID2=ON').ne.0) then ! tape start time
        iscan_last=iscan_last+1
        do i=1,5
          itime_scan(i,iscan_last)=itime_now(i)
        end do
        if(kfirst) then
          kfirst=.false.
          iscan_start=iscan_last
        endif

! See if tape has started moving.
      else if (ctmp(1:2) .eq. 'ET' .or.
     >         ctmp(1:10) .eq. 'DISK_END' .or.
     >         ctmp(1:10) .eq. 'DISC_END' .or.
     >         ctmp(1:15) .eq. 'DISK_RECORD=OFF') then

        do iscan=iscan_start,iscan_last
          idur(iscan)=itimedifsec(itime_now,itime_scan(1,iscan))
        end do
        kfirst=.true.
      endif
      goto 100

200   continue

!cleanup
      do iscan=iscan_start,iscan_last
        idur(iscan)=itimedifsec(itime_now,itime_scan(1,iscan))
      end do

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
      write(ldum,*) "mv ", ltmpfil(1:i1+1),lfile(1:i2)
      call system(ldum)
      return
      end











