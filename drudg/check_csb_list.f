      subroutine check_csb_list(lcsb_list,num_csb,
     >      lsked_csb,num_tracks,imask,ierr)
      implicit none 
! Check to see if all of the elements in lsked_csb are in lcsb_list.
! If not, return with error.
! If so,  set imask.
! Passed
      character*4 lcsb_list(*)  
      integer num_csb
      character*4 lsked_csb(*)
      integer num_tracks                 
  
! output
      integer*4 imask     !mask if any
      integer   ierr 
! Function
      integer iwhere_in_string_list 
! History
! 2015Jun10 JMG First version. 
! local
      integer*4 itemp
      integer ic    !counter
      integer ibit   
      logical kdebug
!      kdebug=.true.   
      kdebug=.false.
      imask=0
      do ic=1,num_tracks
        ibit=iwhere_in_string_list(lcsb_list,num_csb,lsked_csb(ic))
        if(ibit .eq. 0) then              
          if(kdebug)  then
             write(*,*) " "
             write(*,"('     Did not find: ',a)")  lsked_csb(ic)  
             write(*,"('Checking: ', $)") 
          endif 
          ierr=-1
          return
        endif
        itemp=1
        itemp=ishft(itemp,ibit-1)
        imask=ior(imask,itemp)    !set the appropriate bit.
      end do 
! Success.  Found matches for all.
      ierr=0
      return     
      end
!
