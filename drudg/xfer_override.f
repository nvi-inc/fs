      subroutine xfer_override(luscn)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'
! Various data transfer function overrides.
      integer trimlen
! passed
      integer luscn
! local
      character*128 ldestin
      integer ifunc
      character*256 ldum
      logical ktoken,knospace,keol
      integer istart,inext
      character*3 lyes_no
      logical kreturn
      integer nch

      if(luscn .le. 0) return
      kreturn=.false.

! Display current condition.
50    continue

      write(luscn,'(a)') " "
      write(luscn,'(a)') "---CURRENT DATA TRANSFER OVERRIDE OPTIONS---"
      write(luscn,'(a)') " "

      write(luscn,'(a,a)')     "TURN OFF all data transers:  ",
     >   lyes_no(kNo_Data_xfer)
      write(luscn,'(a,a)')     "IN2NET changed to DISK2FILE: ",
     >   lyes_no(kin2net_2_disk2file)

      nch=trimlen(ldestin_in2net)
      if(nch .eq. 0) nch=1

      write(luscn,'(a,a,a,a)') "DISK2FILE changed to IN2NET: ",
     >   lyes_no(kdisk2file_2_in2net), "       Destination: ",
     >   ldestin_in2net(1:nch)


      nch=trimlen(lglobal_in2net)
      if(nch .eq. 0) nch=1

      write(luscn,'(a,a,a,a)') "Global in2net destination:   ",
     >   lyes_no(kglobal_in2net),      "       Destination: ",
     >   lglobal_in2net(1:nch)


      if(kreturn) return


      write(luscn,'(a)') " "
      write(luscn,'(a)') "----CHANGE DATA TRANSFER OVERRIDE OPTIONS----"
      write(luscn,'(a)')
     >   " 0 = Return to drudg (no changes)"
      if(kno_data_xfer) then
         write(luscn,'(a)')
     >      " 1 = Turn on datatransfer statements."
      else
         write(luscn,'(a)')
     >      " 1 = Ignore all datatransfer statements."
      endif
      write(luscn,'(a)')
     >   " 2 = Turn off all overrides. "

      write(luscn,'(a)')
     >   " 3 = Convert In2Net to Disk2file (must edit filenames)"
      write(luscn,'(a)')
     >   " 4 = Convert Disk2file to In2Net. Enter optional destination."
      write(luscn,'(a)')
     >   " 5 = Use global In2Net destination:  "

      write(luscn,*)
      write(luscn,'(a)') "Enter option: "

! Read the response
      read(*,'(a256)') ldum
      istart=1
      ldestin=" "
      call ExtractNextToken(ldum,istart,inext,ldestin,ktoken,
     >  knospace, keol)

      read(ldestin,*,err=50) ifunc

! get the optional filename
      if(ifunc .eq. 4 .or. ifunc .eq. 5) then
        ldestin=" "
        istart=inext
        call ExtractNextToken(ldum,istart,inext,ldestin,ktoken,
     >     knospace, keol)
      endif

100   continue
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
        ldestin_in2net=ldestin
      else if(ifunc .eq. 5) then
        kglobal_in2net=.not.kglobal_in2net
        lglobal_in2net=ldestin
      endif
      kreturn=.true.
      goto 50

200   continue
      write(*,*) "Invalid response. Try again."
      goto 50
      end
