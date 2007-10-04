      subroutine xfer_override(lutmp)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'
      include 'drcom.ftni'
! 2006Jul17.  changed ldisk2file_string ->lautoftp_string
!             Add a "/" to ldisk2file_dir if it is missing.
! 2006OCt06.  Rewritten to clean up user interface.

! Various data transfer function overrides.
      integer trimlen
! passed
      integer lutmp
! local
      character*128 ltemp
      integer ifunc
      character*256 ldum
      character*3 lyes_no
      logical kreturn

      integer MaxToken
      integer NumToken
      parameter(MaxToken=2)
      character*128 ltoken(MaxToken)
      equivalence (ltemp,ltoken(2))

      if(lutmp .le. 0) return
      kreturn=.false.

! Display current condition.
50    continue

      write(lutmp,'(a)') " "
      write(lutmp,'(a)')
     >"-----CURRENT DATA TRANSFER OPTIONS------"
!     write(lutmp,'(a)') " "


      write(lutmp,'(a)')   " [0]  or <RET> Return to drudg "
      write(lutmp,'(a)')   " [1] Turn off all overrides"
      write(lutmp,'(a)') " "

      write(lutmp,'(a,a)') " [2] TURN OFF all data transers:  ",
     >   lyes_no(kNo_Data_xfer)
      write(lutmp,'(a,a)') " [3] IN2NET changed to DISK2FILE: ",
     >   lyes_no(kin2net_2_disk2file)

      write(lutmp,'(a,a)') " [4] DISK2FILE changed to IN2NET: ",
     >  lyes_no(kdisk2file_2_in2net)
      write(lutmp,'(a,a)') " [5] Global IN2NET destination:   ",
     > lyes_no(kglobal_in2net)

      write(lutmp,'(a,a)') " [6] AutoFTP ON:                  ",
     > lyes_no(kautoftp)

      write(lutmp,'(a)')

      if(ldestin_in2net .ne. " ") then
        ltemp=ldestin_in2net
      else
        ltemp="<NONE>"
      endif
      write(lutmp,'(a,a)')
     > " [7] In2Net Destination:          ", ltemp(1:trimlen(ltemp))

      if(lglobal_in2net .ne. " ") then
        ltemp=lglobal_in2net
      else
        ltemp="<NONE>"
      endif
      write(lutmp,'(a,a)')
     > " [8] Global In2Net Destination:   ", ltemp(1:trimlen(ltemp))

      if(lautoftp_string .ne. " ") then
        ltemp=lautoftp_string
      else
        ltemp="<NONE>"
      endif
      write(lutmp,'(a,a)')
     > " [9] AutoFtp_String:              ", ltemp(1:trimlen(ltemp))


      if(ldisk2file_dir .ne. " ") then
        ltemp=ldisk2file_dir
      else
        ltemp="<NONE>"
      endif
      write(lutmp,'(a,a,$)')
     > "[10] Disk2File_Dir:               ", ltemp(1:trimlen(ltemp))
      if(ltemp .eq. "<NONE>") then
         write(lutmp,'(a)') "    Uses Mark5 working directory"
      else
         write(lutmp,'()')
      endif


      if(kreturn) return

      write(lutmp,'(a)')
     >"----------------------------------------"
      write(lutmp,'(a)') " Enter <CMD> <Optional Parameter> "
      write(lutmp,'(a)')
     > " If <Optional Parameter> is missing, value set to <NONE>. "
      write(lutmp,'(a)')
     > " Disk2File_Dir absolute path names preferred."
      write(lutmp,'(a)')
      write(lutmp,'("? ",$)')


! Read the response
      read(*,'(a256)') ldum
      ifunc=trimlen(ldum)
      if(ifunc .eq. 0) return

      ltoken(2)=""
      ltoken(1)=""
      call splitNtokens(ldum,ltoken,Maxtoken,NumToken)
      read(ltoken(1),*,err=200) ifunc

      if(ifunc .lt. 0 .or. ifunc .gt. 10) goto 200

100   continue
      kreturn=.false.
      if(ifunc .eq. 0) then
        kreturn=.true.
      else if(ifunc .eq. 1) then
        kno_data_xfer      =.false.
        Kin2Net_2_Disk2File=.false.
        kDisk2File_2_in2net=.false.
        kglobal_in2net     =.false.
        ldestin_in2net=" "
        lglobal_in2net=" "
        kAutoFTP           =kautoftp0
        ldisk2file_dir     =ldisk2file_dir0
        lautoftp_string    =lautoftp_string0
      else if(ifunc .eq. 2) then
        kno_data_xfer=.not.kno_data_xfer
        if(kno_data_xfer) then
           write(*,*) "Ignoring all data transfer statements."
        else
           writE(*,*) "Using data transfer statements."
        endif
      else if(ifunc .eq. 3) then
        Kin2Net_2_Disk2File=.not.Kin2Net_2_Disk2File
        kno_data_xfer=.false.
      else if(ifunc .eq. 4) then
        kDisk2File_2_in2net=.not.KDisk2File_2_in2net
        kno_data_xfer=.false.
        ldestin_in2net=ltemp
      else if(ifunc .eq. 5) then
        kglobal_in2net=.not.kglobal_in2net
        kno_data_xfer=.false.
      else if(ifunc .eq. 6) then
        kautoftp=.not.kautoftp
! Here is where we set the various strings.
      else if(ifunc .eq. 7) then
        ldestin_in2net=ltoken(2)
      else if(ifunc .eq. 8) then
        lglobal_in2net=ltoken(2)
      else if(ifunc .eq. 9) then
        lautoftp_string=ltoken(2)
      else if(ifunc .eq. 10) then
        ldisk2file_dir=ltoken(2)
        call add_slash_if_needed(ldisk2file_dir)
      endif
!      kreturn=.true.
      goto 50

200   continue
      write(*,*) "Invalid response. Try again."
      goto 50
      end
