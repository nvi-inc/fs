      subroutine lv_open(ierr)

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C OUTPUT
      integer ierr
C LOCAL
      character*128 cfile
      character*256 inbuf
      character*3 cans
      integer il,trimlen
      logical ex

C  1. Prompt for output file name cfile=''

      ierr=-1
      cfile=''
      do while (cfile.eq.'')
        write(luscn,'("Enter name of output file, :: to quit  ",$)')
        read (luusr,'(a)') cfile
        il = trimlen(cfile)
        if (cfile(1:2).eq.'::') return
        inquire(file=cfile,exist=ex,iostat=ierr)
        if (ex) then ! file exists
          do while (cans(1:1).ne.'o'.and.cans(1:1).ne.'a')
            write(luscn,'("Output file already exists, (o)verwrite",
     .      " or (a)ppend, :: to quit  ",$)')
            read (luusr,'(a)') cans
            if (cans(1:2).eq.'::') return
          enddo
          open(unit=LU_outfile,file=cfile,status='old',iostat=IERR)
          if (cans(1:1).eq.'a') then ! read to end
            do while (.true.)
              read(lu_outfile,'(A)',end=777,iostat=ierr) inbuf
            enddo
777         if (ierr.ne.0.and.ierr.ne.-1) then
              write(luscn,9060) ierr,cfile(1:il)
9060          format(' LV_OPEN - Error ',i5,' positioning file ',A)
              return
            endif
          endif
        else ! new file
          open(unit=LU_outfile,file=cfile,status='new',iostat=IERR)
          if (ierr.ne.0) then
            write(luscn,'("LVOPEN01 - Error ",i5," opening file ",
     .      a)') cfile(1:il)
            return
          endif
        endif ! file exists/new file
      enddo 
      return
      end
