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

      if(luscn .le. 0) return
      kreturn=.false.

! Display current condition.
50    continue
      if(ldestin_in2net .eq. " ") then
         ldestin="DEFAULT"
      else
         ldestin=ldestin_in2net
      endif


      write(luscn,'(a)') " "
      write(luscn,'(a)') "---CURRENT DATA TRANSFER OVERRIDE OPTIONS---"
      write(luscn,'(a)') " "
      write(luscn,'(a,a)') "DISK2FILE changed to IN2NET: ",
     >   lyes_no(kdisk2file_2_in2net)
      write(luscn,'(a,a,a,a)') "IN2NET changed to DISK2FILE: ",
     >   lyes_no(kin2net_2_disk2file), "       Destination: ",
     >   ldestin(1:trimlen(ldestin))

      write(luscn,'(a,a)') "TURN OFF all data transers:  ",
     >   lyes_no(kNoDataTransfer)
      if(kreturn) return


      write(luscn,'(a)') " "
      write(luscn,'(a)') "----CHANGE DATA TRANSFER OVERRIDE OPTIONS----"
      write(luscn,'(a)')
     >   " 0 = Return to drudg (no changes)"
      write(luscn,'(a)')
     >   " 1 = Convert In2Net to Disk2file (use default filenames)"
      write(luscn,'(a)')
     >   " 2 = Convert Disk2file to In2Net. Enter optional destination."
      if(kNoDataTransfer) then
         write(luscn,'(a)')
     >      " 3 = Turn on datatransfer statements."
      else
         write(luscn,'(a)')
     >      " 3 = Ignore all datatransfer statements."
      endif
      write(luscn,'(a)')
     >      " 4 = Turn off all overrides. "

      write(luscn,*)
      write(luscn,'(a)') "Enter option: "

! Read the response
      read(*,'(a256)') ldum
      istart=1
      ldestin=" "
      call ExtractNextToken(ldum,istart,inext,ldestin,ktoken,
     >  knospace, keol)

      read(ldestin,*,err=50) ifunc

      if(ifunc .eq. 2) then
        ldestin=" "
        istart=inext
        call ExtractNextToken(ldum,istart,inext,ldestin,ktoken,
     >     knospace, keol)
      endif

100   continue
      if(ifunc .eq. 0) then
        return
      else if(ifunc .eq. 1) then
        Kin2Net_2_Disk2File=.true.
        kDisk2File_2_in2net=.false.
        kNoDataTransfer=.false.
      else if(ifunc .eq. 2) then
        Kin2Net_2_Disk2File=.false.
        kDisk2File_2_in2net=.true.
        kNoDataTransfer=.false.
        ldestin_in2net=ldestin
      else if(ifunc .eq. 3) then
        kNoDataTransfer=.not.kNoDataTransfer
        Kin2Net_2_Disk2File=.false.
        kDisk2File_2_in2net=.false.
        if(kNoDataTransfer) then
           write(*,*) "Ignoring all data transfer statements."
        else
           writE(*,*) "Using data transfer statements."
        endif
      else if(ifunc .eq. 4) then
        kNoDataTransfer    =.false.
        Kin2Net_2_Disk2File=.false.
        kDisk2File_2_in2net=.false.
        write(*,*) "Unknown option. Returning to Drudg"
      endif
      kreturn=.true.
      goto 50

200   continue
      write(*,*) "Invalid response. Try again."
      goto 50
      end
