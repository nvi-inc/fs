      integer function itras(isb,ibit,ihead,ic,ipass,istn,icode)

      include '../skdrincl/itras_cmn.ftni'

      integer*4 itras_ind
! passed variables.
      integer isb
      integer ibit
      integer ihead
      integer ic
      integer ipass
      integer istn
      integer icode

! local
      integer i
      integer*4 ind

! compute index into array
      ind=itras_ind(isb,ibit,ihead,ic,ipass,istn,icode)

      do i=1,num_val
        if(ind  .eq. indvec(i)) then
            itras=itrasvec(i)
            return
         endif
      end do
      itras=-99
      return
      end
! ***********************************************************************
      integer function itras_size()
      include '../skdrincl/itras_cmn.ftni'
      itras_size=num_val
      return
      end
! **********************************************************************
      integer*4 function itras_ind(isb,ibit,ihead,ic,ipass,istn,icode)
      include '../skdrincl/skparm.ftni'

      integer isb,ibit,ihead,ic,ipass,istn,icode
      itras_ind =         isb-1  +
     >                 2*(ibit-1  +
     >                 2*(ihead-1 +
     >    max_headstack *(ic-1    +
     >    max_chan      *(ipass-1 +
     >    max_subpass   *(istn-1  +
     >    max_stn       *(icode-1))))))
      return
      end
! *********************************************************
      subroutine init_itras()
      include '../skdrincl/itras_cmn.ftni'

      integer ihead,istn
      num_val=0

      do ihead=1,max_headstack
        do istn=1,max_stn
          khead(ihead,istn)=.false.
        end do
      end do

      return
      end
! **************************************************************
      logical function kheaduse(ihead,istn)
      include '../skdrincl/itras_cmn.ftni'
      integer ihead,istn
      if(ihead .le. max_headstack .and. istn .le. max_stn) then
         kheaduse=khead(ihead,istn)
      endif
      return
      end
! *********************************************************
      subroutine set_itras(isb,ibit,ihead,ic,ipass,istn,icode,
     >ivalue)

      include '../skdrincl/itras_cmn.ftni'
! functions.
      integer*4 itras_ind
! passed variables.
      integer isb
      integer ibit
      integer ihead
      integer ic
      integer ipass
      integer istn
      integer icode
      integer ivalue
! local
      integer i
      integer*4 ind

! compute index into array
      ind=itras_ind(isb,ibit,ihead,ic,ipass,istn,icode)

      do i=1,num_val
        if(ind  .eq. indvec(i)) then
           goto 100                       !found a match--exit.
         endif
      end do
! Not found. Add a new entry.
      if(num_val .eq. Max_val) then
        write(*,*) "************WARNING********************"
        write(*,*) "Tried to allocate more than ",max_val
        write(*,*) "Change Max_val in itras_cmn.ftni and recompile."
        stop
      endif

      num_val=num_val+1
100   continue
      khead(ihead,istn)=.true.
      indvec(I)   = ind
      itrasvec(i) = ivalue
!      write(*,*) "ITRAS num_val: ",num_val
      return
      end
