      subroutine delete_comma_and_write(lu_out,ibuf,nch)
!
      integer lu_out
      integer ibuf(*)
      integer nch
      integer ierr
      integer oblank
      data oblank/32/    !ascii space

      nch=nch-1
      CALL IFILL(IBUF,NCH,1,oblank)

      call hol2lower(ibuf,(nch+1))
      CALL writf_asc(LU_OUT,IERR,IBUF,(NCH+1)/2)
      nch=0
      return
      end
