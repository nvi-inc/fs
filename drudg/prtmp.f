      Subroutine prtmp
C  PRTMP prints the temp file
c  NRV 910703
C  nrv 950925 Change to simply call "printer". Landscape or
C             portrait is handled by each listing type.

      include 'skparm.ftni'
      include 'drcom.ftni'
      integer ierr
      integer printer ! function

      if (cprport.ne.'PRINT') return

      call null_term(tmpname)

      if (klab) then ! labels
        write(6,'("prtmp: labels")')
          ierr = printer(tmpname,'r')
      else ! normal prinout
          ierr = printer(tmpname,' ')
C       if (iwidth.eq.80) then
C           ierr = printer(tmpname,cprtpor)
C       else if (iwidth.eq.137) then
C           ierr = printer(tmpname,cprtlan)
C       else
C           ierr = -1
C       end if
      endif

      if (ierr.ne.0) then
         write(luscn,9062) ierr
9062     format(' LISTS02 - Error ',i3,' calling printer')
      else
         open(luprt,file=tmpname,status='old')
         close(luprt,status='delete')
      end if
   
      RETURN
      END
