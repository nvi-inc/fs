      subroutine ChkGrpAndZeroWrite(itrk,istart,iend,ihead,
     >  lname,itrk2, kfound,ibuf,nch)
      implicit none
! fucntions
      integer mcoma
      integer ichmv_ch

! Passed variables
      integer itrk(36,2)        !track list.
      integer istart,iend       !starting, ending location for test.
      integer ihead             !which headstack, 1 or 2?
      character*2 lname         !name of group (if found)
! modified
      integer itrk2(36,2)       !If we find group, then we set corresponding tracks to 0.
      logical kfound            !all tracks that we look at have 1.
      integer ibuf(*)
      integer nch               !Number of characters so far.
! local
      integer i

! 0. See if we find this group. All tracks must be set.
      kfound=.true.
      do i=istart,iend,2
        if(itrk(i,ihead) .eq. 0) then
           kfound=.false.
           return
         endif
      end do
! Group found. Some more processing.

! 1. Zero the second track list
      do i=istart,iend,2
         itrk2(i,ihead)=0
      end do
! 2. put info in the buffer.
      nch=ichmv_ch(ibuf,nch,lname)
      nch = MCOMA(IBUF,nch)     !append comma
      return
      end


















