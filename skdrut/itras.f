! These routines return the track mapping in Mark4 format.
! NOTE: SIDEBANDS assume normal LO. If inverted need to fix downstream. 
! 
! Valid Mark3 tracks are 1-28, which correspond to
! Valid Mark4 tracks are 2-33.
! To map from Mark3+3=Mark4, i.e., Mark3 track 1=Mark4 track 4.
! The sked catalogs keep the track numbers in Mark4 mode, so that
! -1 (mark3) corresponds to Mark4 track 2.
!
! The main function in this file is
!      integer function itras(isb,ibit,ihead,ichn,ipass,istn,icode)
! This returns the track number assigned to this combination if there is one.
! If not, it returns -99.
! Originally this information was stored in an array of dimension
! 2*2*Max_head*Max_chan*Max_stn*max_pass*Max_frq--which was huge
! =2*2*2      *32      *30     *(14*36) *20 =77,414,400 entries.
! This can be simplified considerably when you consider that
! A) For most codes, many stations share the same track assignments.
!    So all you need to do is store distinct track assignments.
! B) A given track assignment is UNIQUELY specified by noting which data is
!    is on what tracks on what pass. This involves 32 X Number of headstacks.
!
! A track assginment is stored as a 33 element array (element 1 is not used.)
! In each slot is stored the (Isb,ibit,ihead,ich,ipass) code which is recorded there.
! If a slot is not used, then -99 is stored there.

! Setting up the Table.
! 1.  The first step is to build up the track assignment.
! This is done in frinp.f (actually unpco.f) and vmoinp.f
! For each track J that is recorded, the function
!    itras_ind(isb,ibit,ihead,ich,ipass)
! assigns a unique integer to each possible combination.
! This number is putinto itrk(J).
!
! 2. When all the tracks for a given mode/station combination are done,
!    the routine add_trk_map is called.
!   This checks to see if this track map is in the array itrk_map.
!   If not it adds it.  In any case, it updates the array istn_cod(istn,icod)
!   with a pointer to the correct track_map.

! To see the track a particular bit/pass/etc combination is written on, if any,
! the function itras is called.
! The first thing this does is get the track map key from istn_cod(istn,icod).
! Then it computes the unique identifier from itras_ind, and sees if this matches
! any of the 32 possible combinations in itrk_map(itrk_key,ihead,*).  If so, it
! returns the track. If not, it returns -99.

!*************************************************************************
      integer function itras(isb,ibit,ihead,ichn,ipass,istn,icode)
      include '../skdrincl/itras_cmn.ftni'

      integer*4 itras_ind
! passed variables.
      integer isb
      integer ibit
      integer ihead
      integer ichn
      integer ipass
      integer istn
      integer icode

! local
      integer i
      integer*4 ind
      integer itrk_key
! Return track that this is written on, or -99 if no track.

      itras=-99
      itrk_key=istn_cod(istn,icode)
      if(itrk_key .eq. 0) then
         if(num_trk_map .ne. 0) then
!           write(*,*) "ITRAS: Mode # ",icode,
!     >       " not defined for station # ",istn
          endif
         return
      endif

      ind=itras_ind(isb,ibit,ichn,ipass)
      do i=1,max_trk
       if(itrk_map(itrk_key,ihead,i) .eq. ind) then
         itras=i
         return
       endif
      end do
      return
      end
!*************************************************************
      logical function ktrack_match(istn1,icode1,istn2,icode2)
      include '../skdrincl/itras_cmn.ftni'

      integer istn1,icode1,istn2,icode2

      ktrack_match=istn_cod(istn1,icode1).eq. istn_cod(istn2,icode2)
      return
      end
! ***************************************************
      subroutine add_trk_map(istn,icod,itrack)
      include '../skdrincl/itras_cmn.ftni'
      integer istn,icod
      integer*4 itrack(max_headstack,max_trk)  !to add

! local
      integer itrk_key,ihd
      integer j
      integer isb,ibit,ichn,ipass

      do itrk_key=1,num_trk_map
        do ihd=1,max_headstack
          do j=1,max_trk
            if(itrack(ihd,j) .ne. itrk_map(itrk_key,ihd,j)) goto 100
          end do
        end do
        goto 200   ! a match
100     continue
      end do
! No match.  Add it in.
      if(num_trk_map .lt. max_trk_map) then
         num_trk_map=num_trk_map+1
      else
        write(*,*) "Exceeded number of tracks maps!"
        write(*,*) "Change itras_cmn and Recompile itras.f"
        stop
      endif
      itrk_key=num_trk_map

      num_pass(itrk_key)=0
      num_trks(itrk_key)=0
      num_head(itrk_key)=0
      num_bits(itrk_key)=1

      do ihd=1,max_headstack
        do j=1,max_trk
          itrk_map(itrk_key,ihd,j)=itrack(ihd,j)
          if(itrack(ihd,j) .ne. -99) then
            khead(ihd,istn)=.true.
            num_trks(itrk_key)=num_trks(itrk_key)+1
            num_head(itrk_key)=ihd

            call itras_ind_2_sb_bit_chn_pass(itrack(ihd,j),
     >             isb,ibit,ichn,ipass)
            if(ibit .eq. 2) then
               num_bits(itrk_key)=2
            endif
            if(ipass .gt. num_pass(itrk_key)) then
               num_pass(itrk_key)=ipass
            endif
          end if
        end do
      end do

! At this point itrk_key points to correct track code.
200   continue
      istn_cod(istn,icod)=itrk_key
      return
      end
! ******************************************************
      subroutine init_itrk_map(itrk)
      include '../skdrincl/skparm.ftni'
      integer*4 itrk(max_headstack,max_trk)
      integer ihd,j

      do ihd=1,max_headstack
        do j=1,max_trk
           itrk(ihd,j)=-99
        end do
      end do
      return
      end
! ***********************************************************************
      subroutine itras_params(istn,icode,npass,ntrks,nhead,nbits)
      include '../skdrincl/itras_cmn.ftni'

! passed
      integer istn
      integer icode
! returned
      integer npass,ntrks,nhead,nbits
! local
      integer itrk_key

      itrk_key=istn_cod(istn,icode)
      if(itrk_key .eq. 0) then
         npass=0
         ntrks=0
         nhead=0
         nbits=0
!        write(*,*) "ITRAS_PARAMS: Invalid Station/Code pair ",istn,icode
        return
      endif

      npass=num_pass(itrk_key)
      ntrks=num_trks(itrk_key)
      nhead=num_head(itrk_key)
      nbits=num_bits(itrk_key)
      return
      end
! **********************************************************************
      integer*4 function itras_ind(isb,ibit,ichn,ipass)
      include '../skdrincl/skparm.ftni'

      integer isb,ibit,ichn,ipass
      itras_ind =         isb-1   +
     >                 2*(ibit-1  +
     >                 2*(ichn-1  +
     >          max_chan*(ipass-1)))
      return
      end
! **********************************************************************
      subroutine itras_ind_2_sb_bit_chn_pass(ind_in,isb,ibit,ichn,ipass)
! opposite of itras_ind
      include '../skdrincl/skparm.ftni'
      integer*4 ind_in
      integer isb,ibit,ichn,ipass
      integer*4 ind

      ind=ind_in

      isb=mod(ind,2)
      ind=(ind-isb)/2
      isb=isb+1

      ibit=mod(ind,2)
      ind=(ind-ibit)/2
      ibit=ibit+1

      ichn=mod(ind,max_chan)
      ind=(ind-ichn)/max_chan
      ichn=ichn+1

      ipass=ind+1
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
      subroutine init_itras()
      include '../skdrincl/itras_cmn.ftni'

      integer ihead
      integer istn,ifrq

      num_trk_map=0

      do ihead=1,max_headstack
      do istn=1,max_stn
        khead(ihead,istn)=.false.
        do ifrq=1,max_frq
          istn_cod(istn,ifrq)=0
        end do
      end do
      end do

      return
      end
