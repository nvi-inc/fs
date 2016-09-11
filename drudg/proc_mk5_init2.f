      subroutine proc_mk5_init2(lform,
     >   ifan,samprate,ntrack_rec_mk5,luscn,ierr)
      include 'hardware.ftni'
! History:
!  2014Dec06. Added Mark5C support
!  2015Jun05 JMG. Repalced drudg_write by drudg_write. 
!  2016May07 WEH. bank_check if only 2 Gbps or less
!  2016Sep08 JMG.  For Mark5c and >2GBS output jiveab commands
! passed
      character*5 lform        !Form descriptor
      integer ifan              !fanout
      real   samprate
      integer luscn             !LU to output error messages (normally the screen).
      integer ntrack_rec_mk5    !number of tracks recorded.
! returned
      integer ierr             !some error
! local
      integer idrate
      character*50 ldum
      integer itemp

      ierr=0
      if(ifan .gt. 1) then
         idrate=samprate/ifan   !idrate is the data rate.
      else
         idrate=samprate
      endif
      if(.not. (km5b .or. km5c)) then             !skip below for Mark5B
! Put some instructions out for MK5 recorders.
        write(ldum,'("mk5=play_rate=data:",i4,";")') idrate
        call drudg_write(lufile,ldum)

        if(km5p_piggy) then
           itemp=32
        else
           itemp=ntrack_rec_mk5
        endif
        write(ldum,'("mk5=mode=",a,":",i2,";")')lform,itemp
        call drudg_write(lufile,ldum)
      endif
      if(.not. kflexbuff .and. .not.
     &     (km5c .and. idrate*ntrack_rec_mk5.gt.2048)) then 
         write(lufile,'("bank_check")')
      endif 
  
      if(km5c .and. .not.kflexbuff) then
        if(idrate*ntrack_rec_mk5.gt.2048) then
          write(lufile,'("jive5ab=vsn?")')
          write(lufile,'("jive5ab=disk_serial?")') 
        endif
      endif 
      end

