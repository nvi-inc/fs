      subroutine snap_hol_wrt(lu_outfile,lhol,nch)
! write out snap holerith command
      implicit none
!function
      integer  ichmv

!passed
      integer lu_outfile
      integer lhol(*)           !some holerith
      integer nch
      integer nch2
! local
      integer*2 ibuf2(50)
      character*100 cbuf2
      equivalence (cbuf2,ibuf2)
      integer iblen
      logical kerr

      iblen=100
      cbuf2=" "
      if(nch .gt. 100) then
        write(*,*) "snap_hol_wrt:  trying to write too big a line!"
        write(*,*) "Max size, current size: ",100,nch
      endif
      nch2 = ICHMV(IBUF2,1,Lhol,1,nch)
      call c2lower(cbuf2(1:nch),cbuf2(1:nch))
      write(lu_outfile,'(a)') cbuf2(1:nch)

!      call hol2lower(ibuf2,(nch2+1))
!      call writf_asc(LU_OUTFILE,KERR,IBUF2,(nch2+1)/2)
      return
      end
