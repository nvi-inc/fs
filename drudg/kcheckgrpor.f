      logical function kCheckGrpOr(itrk,istart,iend,ihead)
! passed
      integer itrk(36,2)
      integer istart,iend
      integer ihead
! local
      integer i

      kCheckGrpOr=.false.
      do i=istart,iend,2
        if(itrk(i,ihead) .eq. 1) then
           kCheckGrpOr=.true.
           return
        endif
      end do
      return
      end
