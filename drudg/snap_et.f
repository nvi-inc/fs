      subroutine snap_et
!     JMGipson   2002Jan02  V1.00
      include 'hardware.ftni'

! Output "et" command.
      if(krec_append) then
        write(luFile,'(a,a1)', err=100) 'et',crec(irec)
      else
        write(luFile,'(a)', err=100) 'et'
      endif

      if(itime2stop .ne. 0) then
        write(luFile,'("!+",i1,"s")',err=100) itime2Stop
      endif

      return

100   continue 
      return
      end

