      subroutine purge_file(lfilnam,luscn,luusr,kbatch,ierr)
      implicit none
! functions
      integer trimlen
      character upper
! passed
      character*(*) lfilnam             !file to purge
      logical kbatch                    !batch mode. Don't check.
      integer ierr                      !ierr<>0, not purged.
      integer luscn,luusr               !output, input lus.
! local
      logical kexist
      character*1 lchar
      integer ic
      integer lu_outfile                !only used to delete file.
      logical kdone

      inquire(file=lfilnam,exist=kexist,iostat=ierr)
      ic = trimlen(lfilnam)
      if (kexist) then
        if(.not. kbatch) then
          kdone = .false.
          do while (.not.kdone)
            write(luscn,9130) lfilnam(1:ic)
9130        format(' OK to purge existing file ',A,' (Y/N) ? ',$)
            read(luusr,'(A)') lchar
            lchar(1:1) = upper(lchar(1:1))
            if (lchar(1:1).eq.'N') then
              ierr=1
              return
            else if (lchar(1:1).eq.'Y') then
              kdone = .true.
            end if
          end do
        end if
        ierr=0
        open(lu_outfile,file=lfilnam)
        close(lu_outfile,status='delete')
      endif
      return
      end
