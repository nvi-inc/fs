      integer function iroll_def(istep,idef,istn,icode)

      include '../skdrincl/iroll_def_cmn.ftni'
! function
      integer*4 ind_iroll_def

! passed variables.
      integer istep
      integer idef
      integer icode
      integer istn

! local
      integer i
      integer*4 ind

      ind=iroll_def_ind(istep,idef,istn,icode)

      do i=1,num_val
        if(ind .eq. iroll_def_indvec(i)) then
            iroll_def=iroll_defvec(i)
            return
         endif
      end do
      iroll_def=-99
      return
      end
! ***********************************************************************
      integer function iroll_def_size()
      include '../skdrincl/iroll_def_cmn.ftni'
      iroll_def_size=num_val
      return
      end
! **********************************************************************
      integer*4 function iroll_def_ind(istep,idef,istn,icode)

      include '../skdrincl/skparm.ftni'
! dimensions of array are (2+max_track)*(max_track*max_head)*(max_stn)*max_frq

      integer istep,idef,istn,icode
      iroll_def_ind =              istep-1  +
     >               (2+max_track)*(idef-1  +
     >   (max_track*max_headstack)*(istn-1  +
     >              max_stn       *(icode-1)))
      return
      end

! *********************************************************
      subroutine init_iroll_def()
      include '../skdrincl/iroll_def_cmn.ftni'

      num_val=0
      return
      end

! *********************************************************
      subroutine set_iroll_def(istep,idef,istn,icode,ivalue)

      include '../skdrincl/iroll_def_cmn.ftni'
! function
      integer*4 ind_iroll_def
! passed variables.
      integer istep
      integer idef
      integer icode
      integer istn
      integer ivalue

! local
      integer i
      integer*4 ind

      ind=iroll_def_ind(istep,idef,istn,icode)

      do i=1,num_val
        if(ind .eq. iroll_def_indvec(i)) then
           goto 100
        endif
      end do
! Not found. Add a new entry.
      if(num_val .eq. Max_val) then
        write(*,*) "************WARNING********************"
        write(*,*) "Tried to allocate more than ",max_val
        write(*,*) "Change Max_val in iroll_def_cmn.ftni and recompile."
        stop
      endif

! didn't find a match. update table.
      num_val=num_val+1
100   continue
      iroll_def_indvec(i)=ind
      iroll_defvec(i) =ivalue
      if(mod(i,100) .eq. 1) then
!      write(*,*) "iroll_def num_val: ",num_val
      endif
      return
      end
