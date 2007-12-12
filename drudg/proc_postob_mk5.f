      subroutine proc_postob_mk5(lu_outfile,luscn)
! write out postob_mk5 routine
      include 'hardware.ftni'
! passed
      integer lu_outfile
      integer luscn
! local
      integer i
      character*12 cnamep

      cnamep="postob_mk5"

      call proc_write_define(lu_outfile,luscn,cnamep)

      do i=1,8
        write(lu_outfile,'(a)') "mk5=get_stats?"
      end do

      write(lu_outfile,'(a)') "mk5=status?"
      write(lu_outfile,'(a)') "postob"
      write(lu_outfile,'(a)') "enddef"
      return
      end