      subroutine snap_mk5_init1(ntrcks_rec,ntrcks_rec_mk5,ierr)
      include 'hardware.ftni'
! passed
      integer ntrcks_rec       !number of tracks we normally record on
! returned
      integer ntrcks_rec_mk5   !number we actually used  in mk5 (must be 8,16,32 or 64
      integer ierr             !some error
! local
      character*50 ldum
      integer idatarate

      ierr=0
! Put some instructions out for MK5 recorders.
90    format(a)
      if(km5p) then
        if(km4form) then
           write(lufile,90)'"connect the Mark 5P recorder to the"'
           write(lufile,90)'"headstack 2 output of the formatter"'
         else if(kvrack) then
           write(lufile,90)'"connect the Mark 5P recorder to the"'
           write(lufile,90)'"second recorder output of the formatter"'
         endif
      else if(km5) then
! setup for number of tracks observed and recorded.
        if(ntrcks_rec .lt. 4) then
           write(luscn,*) "PROCS: Too few tracks in Mk5 mode!"
           write(luscn,*) "aborting"
           ierr=1
           return
         endif
         ntrcks_rec_mk5=8                 !can only record in units of 8,16, 32,64
         do i=1,4
           if(ntrcks_rec .le.ntrcks_rec_mk5) goto 5
           ntrcks_rec_mk5=ntrcks_rec_mk5*2
         end do
5        continue
! put commands in setup.
         if(km4form) then
           lform="mark4"
           write(lufile,90)'"connect the Set 1 Mark 5A recorder input"'
           write(lufile,90)'"headstack 1 output of the formatter"'
           if(ntrcks_rec .gt. 32) then
            write(lufile,90)'"connect the Set 2 Mark 5A recorder input"'
            write(lufile,90)'"headstack 2 output of the formatter"'
           endif
         else if(kvrack) then
           lform="vlba"
           write(lufile,90)'"connect the Mark 5A recorder to the"'
           write(lufile,90)'"second recorder output of the formatter"'
         endif
! Bank check commands.
         if(ifan(istn,icode) .gt. 1) then
            idatarate=samprate(1)/ifan(istn,icode)
         else
           idatarate=samprate(1)
         endif
         write(ldum,'("mk4=mode=",a,":",i2,";")')lform,ntrcks_rec_mk5
         call squeezewrite(lufile,ldum)
         write(ldum,'("mk4=play_rate=data:",i4)') idatarate
         call squeezewrite(lufile,ldum)
         write(lufile,'("bank_check")')
      endif
      return
      end

