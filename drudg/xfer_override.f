      subroutine xfer_override(lutmp)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'
      include 'drcom.ftni'
! Various data transfer function overrides.
      integer trimlen
! passed
      integer lutmp
! local
      character*128 ltemp
      integer ifunc
      character*256 ldum
      logical ktoken,knospace,keol
      integer istart,inext
      character*3 lyes_no
      logical kreturn
      integer nch

      if(lutmp .le. 0) return
      kreturn=.false.

! Display current condition.
50    continue

      write(lutmp,'(a)') " "
      write(lutmp,'(a)') "---CURRENT DATA TRANSFER OVERRIDE OPTIONS---"
      write(lutmp,'(a)') " "

      write(lutmp,'(a,a)')     "TURN OFF all data transers:  ",
     >   lyes_no(kNo_Data_xfer)
      write(lutmp,'(a,a)')     "IN2NET changed to DISK2FILE: ",
     >   lyes_no(kin2net_2_disk2file)

      if(ldestin_in2net .ne. " ") then
        ltemp=ldestin_in2net
      else
        ltemp="<NONE>"
      endif
      nch=trimlen(ltemp)
      write(lutmp,'(a,a,a,a)') "DISK2FILE changed to IN2NET: ",
     >   lyes_no(kdisk2file_2_in2net), "       Destination: ",
     >   ltemp(1:nch)

      if(lglobal_in2net .ne. " ") then
        ltemp=lglobal_in2net
      else
        ltemp="<NONE>"
      endif
      nch=trimlen(ltemp)

      write(lutmp,'(a,a,a,a)') "Global in2net destination:   ",
     >   lyes_no(kglobal_in2net),      "       Destination: ",
     >   ltemp(1:nch)

      write(lutmp,'(" ")')

      nch=max(1,trimlen(ldisk2file_dir))

      if(ldisk2file_dir .ne. " ") then
        ltemp=ldisk2file_dir
      else
        ltemp="<NONE>"
      endif
      nch=trimlen(ltemp)
      write(lutmp,'("DISK2FILE_DIR:      ",a)')  ltemp(1:nch)

      if(ldisk2file_node .ne. " ") then
        ltemp=ldisk2file_node
      else
        ltemp="<NONE>"
      endif
      nch=trimlen(ltemp)
      write(lutmp,'("DISK2FILE_NODE:     ",a)')  ltemp(1:nch)


      if(ldisk2file_userid .ne. " ") then
        ltemp=ldisk2file_userid
      else
        ltemp="<NONE>"
      endif
      nch=trimlen(ltemp)
      write(lutmp,'("DISK2FILE_USERID:   ",a)')  ltemp(1:nch)

      if(ldisk2file_pass .ne. " ") then
        ltemp=ldisk2file_pass
      else
        ltemp="<NONE>"
      endif
      nch=trimlen(ltemp)
      write(lutmp,'("DISK2FILE_PASSWORD: ",a)')  ltemp(1:nch)

      if(kreturn) return

      write(lutmp,'(a)') " "
      write(lutmp,'(a)') "----CHANGE DATA TRANSFER OVERRIDE OPTIONS----"
      write(lutmp,'(a)')
     >   " 0 = Return to drudg (no changes)"
      if(kno_data_xfer) then
         write(lutmp,'(a)')
     >      " 1 = Turn on datatransfer statements."
      else
         write(lutmp,'(a)')
     >      " 1 = Ignore all datatransfer statements."
      endif
      write(lutmp,'(a)')
     >   " 2 = Turn off all overrides. "

      write(lutmp,'(a)')
     >   " 3 = Convert In2Net to Disk2file (must edit filenames)"
      write(lutmp,'(a)')
     >   " 4 = Convert Disk2file to In2Net. Enter optional destination."
      write(lutmp,'(a)')
     >   " 5 = Use global In2Net destination:  "
      write(lutmp,'(a)') " 6 = Change Disk2file_dir "
      write(lutmp,'(a)') " 7 = Change Disk2file_node "
      write(lutmp,'(a)') " 8 = Change Disk2file_userid "
      write(lutmp,'(a)') " 9 = Change Disk2file_password "


      write(lutmp,*)
      write(lutmp,'(a)') "Enter option: "

! Read the response
      read(*,'(a256)') ldum
      istart=1
      ltemp=" "
      call ExtractNextToken(ldum,istart,inext,ltemp,ktoken,
     >    knospace,keol)

      read(ltemp,*,err=50) ifunc

! get the optional filename
      if(ifunc .ge. 4) then
        ltemp=" "
        istart=inext
        call ExtractNextToken(ldum,istart,inext,ltemp,ktoken,
     >     knospace, keol)
      endif

100   continue
      kreturn=.false.
      if(ifunc .eq. 0) then
        kreturn=.true.
        goto 50
      else if(ifunc .eq. 1) then
        kno_data_xfer=.not.kno_data_xfer
        if(kno_data_xfer) then
           write(*,*) "Ignoring all data transfer statements."
        else
           writE(*,*) "Using data transfer statements."
        endif
      else if(ifunc .eq. 2) then
        kno_data_xfer    =.false.
        Kin2Net_2_Disk2File=.false.
        kDisk2File_2_in2net=.false.
      else if(ifunc .eq. 3) then
        Kin2Net_2_Disk2File=.not.Kin2Net_2_Disk2File
        kno_data_xfer=.false.
      else if(ifunc .eq. 4) then
        kDisk2File_2_in2net=.not.KDisk2File_2_in2net
        kno_data_xfer=.false.
        ldestin_in2net=ltemp
      else if(ifunc .eq. 5) then
        kglobal_in2net=.not.kglobal_in2net
        lglobal_in2net=ltemp
      else if(ifunc .eq. 6) then
        ldisk2file_dir=ltemp
      else if(ifunc .eq. 7) then
        ldisk2file_node=ltemp
      else if(ifunc .eq. 8) then
        ldisk2file_userid=ltemp
        call put_esc_in_string(ldisk2file_userid)
      else if(ifunc .eq. 9) then
        ldisk2file_pass=ltemp
      endif
!      kreturn=.true.
      goto 50

200   continue
      write(*,*) "Invalid response. Try again."
      goto 50
      end
