      subroutine proc_mk5_init2(ifan,samprate,ntrack_rec_mk5,luscn,ierr)
      implicit none
      include 'hardware.ftni'
! passed
      integer ifan              !fanout
      real   samprate
      integer luscn             !LU to output error messages (normally the screen).
      integer ntrack_rec_mk5    !number of tracks recorded.
! returned
      integer ierr             !some error
! local
      integer idrate
      character*5 lform        !Rack discriptor
      character*50 ldum
      integer itemp

      ierr=0

      if(ifan .gt. 1) then
        idrate=samprate/ifan        !idrate is the data rate.
      else
        idrate=samprate
      endif

! Put some instructions out for MK5 recorders.
      if(km4form) then
         lform="mark4"
      else if(kvrack) then
         lform="vlba"
      endif

      write(ldum,'("mk5=play_rate=data:",i4)') idrate
      call squeezewrite(lufile,ldum)

      if(km5a_piggy) then
         itemp=32
      else
         itemp=ntrack_rec_mk5
      endif
      write(ldum,'("mk5=mode=",a,":",i2,";")')lform,itemp
      call squeezewrite(lufile,ldum)

      write(lufile,'("bank_check")')
      end

