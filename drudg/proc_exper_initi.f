      subroutine proc_exper_initi(lufil,luscn,kin2net_on)
      implicit none
      include 'hardware.ftni'
! passed
      integer lufil,luscn
      logical kin2net_on

! functions

! local
      character*12 lname

      lname="exper_initi"

      call proc_write_define(luFil,luscn,lname)
      write(luFile,'(a)') "proc_library"
      write(luFile,'(a)') "sched_initi"

      if(km5A .or. km5A_piggy) then
        if(kin2net_on) then
          write(lufile,'("mk5=net_protocol=tcp:4194304:2097152")')
        endif
        write(lufile,'(a)')   "mk5=DTS_id?"
        write(lufile,'(a)')   "mk5=OS_rev1?"
        write(lufile,'(a)')   "mk5=OS_rev2?"
        write(lufile,'(a)')   "mk5=SS_rev1?"
        write(lufile,'(a)')   "mk5=SS_rev2?"
        write(lufile,'(a)')   "mk5=status?"
      endif
      write(lufile,'(a)') "enddef"

      return
      end

