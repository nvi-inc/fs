      Subroutine prtmp
C  PRTMP prints the temp file
c  NRV 910703
C  nrv 950925 Change to simply call "printer". Landscape or
C             portrait is handled by each listing type.
C  nrv 951015 Revert to using cprtpor and cprtlan , and if blank
C             then "printer" will handle them.

      include 'skparm.ftni'
      include 'drcom.ftni'
      integer ierr
      integer printer ! function

      if (cprport.ne.'PRINT') return

      call null_term(tmpname)

      if (klab) then ! labels
        ierr = printer(tmpname,'r')
      else ! normal prinout
        if (iwidth.eq.80) then
          ierr = printer(tmpname,cprtpor)
        else if (iwidth.eq.137) then
          ierr = printer(tmpname,cprtlan)
        else
          ierr = -1
        end if
      endif

      if (ierr.ne.0) then
         write(luscn,9062) ierr
9062     format(' PRINTER01 - Error ',i5,' calling printer')
      else
         open(luprt,file=tmpname,status='old')
         close(luprt,status='delete')
      end if
   
      RETURN
      END
