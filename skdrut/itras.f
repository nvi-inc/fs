! BEGIN Modified 2015-Jun-02. JMGipson.
!   Previously tape recording assumed that Sign and magnitude bits were recorded on separate tracks.
!   To support DIFX correlation we need to add the possibility that they will be on same track.
!   This is done by storing TWO track tables--one for sign, and one for magnitude. The rest of 
!   the logic is basically the same. 
! 
! END 2015-Jun-02
!
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
! Originally (pre 2001) this information was stored in an array of dimension
! 2*2*Max_head*Max_chan*Max_stn*max_pass*Max_frq--which was huge
! =2*2*2      *32      *30     *(14*36) *20 =77,414,400 entries.
! This can be simplified considerably when you consider that
! A) For most codes, many stations share the same track assignments.
!    So all you need to do is store distinct track assignments.
! B) A given track assignment is UNIQUELY specified by noting which data is
!    is on what tracks on what pass. 
!
! A track assignment is stored as an array of dimension:  itrack_map(2,ihead,max_track)
! The 2 is for Sign/magnitude. For Tape recording code not record sign/magnitude on the same track.
! However, under VDIF you can.
! 
! USage:
!  call init_tras()       This initilizes the routines.
!
!  call new_track_map()   This indicates that we are processing a new track map. 
!                         NOTE--this may be identical to an existing one--we just don't know.
!
!  call add_track(itrack,isb,ibit,ihead,ichan,ipas) 
!                         We add a track. This track records isb,ibit,ihead,ichan,ipas.
!                         This also updates information like number of passes, number of bits, etc. 
!
!  call add_track_map(istn,icode) 
!                         This is called when we have added all of the tracks to a given track map.
!                         If neccessary it adds this map to the list  itrack_map_vec.
!                         In any case, it updateds the array istn_code_key, pointing to the correct map.
!
! itemp=itras(isb,ibit,ihead,ichn,ipass,istn,icode)
!                         Returns track this info is written on, or -99 if no track. 
!                   
!     ktrack_match(istn1,icod1,istn2,icod2)   
!                         True if the tracks are the same for the two cases.
!  
!  call itras_params(istn,icode,npass,ntracks,nhead,nbits)
!                         For (istn,icode), return number of passes, number of tracks, number of heads, 1 or 2 bit recording. 
!
!*************************************************************************
      integer function itras(isb,ibit,ihead,ichn,ipass,istn,icode)      
      include 'itras_cmn.ftni'
! Return the trackt used for recording for isb,ibit,ihead,ichn,ipass,istn,icode.
! If no track, return -99. 
     
! passed variables.
      integer isb
      integer ibit
      integer ihead
      integer ichn
      integer ipass
      integer istn
      integer icode
! function
      integer*4 itras_magic 

! local
      integer*4 imagic    !magic number. Unique number for (isb,ibit,ichn,ipass)
      integer imap
      integer itrack 
! Return track that this is written on, or -99 if no track.

! Check to see if this mode has been defined for this station.
      imap=istn_code_key(istn,icode)
      if(imap .eq. 0) then
         if(num_track_map .ne. 0) then
!           write(*,*) "ITRAS: Mode # ",icode,
!     >       " not defined for station # ",istn
          endif
         return
      endif

! Mode defined. Now find the special number for this. 
      imagic=itras_magic(isb,ibit,ichn,ipass)
      do itras=1,max_tracks(imap) 
!        write(*,*) ibit,ihead,itras,imap
        if(itrack_map_vec(ibit,ihead,itras,imap) .eq. imagic) 
     >      goto 100                 !found a match.     
      end do
      itras=-99 
100   continue  
  
     
      return
      end
!*************************************************************
      logical function ktrack_match(istn1,icode1,istn2,icode2)
      include 'itras_cmn.ftni'

      integer istn1,icode1,istn2,icode2

      ktrack_match=istn_code_key(istn1,icode1).eq.
     &             istn_code_key(istn2,icode2)
      return
      end
! ******************************************************
      subroutine new_track_map()  
      include 'itras_cmn.ftni'
      integer ihd,itrack,ibit
! Set all of 'itrack_map' to -99=not recorded. 
      kdebug_itras=.false. 

      do ihd=1,max_headstack
        do ibit=1,2
          do itrack=1,max_track
            itrack_map(ibit,ihd,itrack)=-99
          end do
        end do 
      end do
!      write(*,*) "New map"
      if(kdebug_itras) then 
          write(*,'(a)') 
     &      "   Trk Magic    SB   Bit   Chan   Pass" 
      endif 
      itrack_map_key=0


      num_tracks_new=0
      max_tracks_new =0
      num_pass_new=0
      num_head_new=0
      num_bits_new=0
      return
      end
! ************************************************************   
      subroutine add_track(itrack,isb,ibit,ihead,ichan,ipas) 
      include 'itras_cmn.ftni'
! Add a new track to itrack_map.
      integer itrack,isb,ibit,ihead,ichan,ipas

      integer*4 itras_magic 
      if(itrack_map(ibit,ihead,itrack) .ne. -99) then
        write(*,*) 
     >   "ITRAS(add_Track):  Track is already used in this mode!"
         stop
      endif  
      itrack_map(ibit,ihead,itrack)=itras_magic(isb,ibit,ichan,ipas)

      if(kdebug_itras) then 
         write(*,'(6i6)') itrack, itrack_map(ibit,ihead,itrack),
     &   isb,ibit,ichan,ipas
      endif 

      num_tracks_new = num_tracks_new+1      
      num_pass_new   = max(num_pass_new,ipas)
      num_head_new   = max(num_head_new,ihead)
      num_bits_new   = max(num_bits_new,ibit)
      max_tracks_new = max(max_tracks_new,itrack) 
   
      return
      end
! ***************************************************
      subroutine add_track_map(istn,icod) 
      include 'itras_cmn.ftni'
      integer istn       !station
      integer icod       !code

! Add the track map "itrack_map" to the list of track maps for (istn,icode) 
   
! local 
      integer imap                !counters over track_maps
      integer ibit,ihd,itrack     !indices

! If it was already added, return. 
      if(itrack_map_key .ne. 0) then
!        write(*,*) "Previous map " 
        istn_code_key(istn,icod)=itrack_map_key
        return
      endif 
 
! Don't know where this map belongs (if it does.)
! Check if in list of previous track maps.         

      do imap=1,num_track_map
        do ihd=1,max_headstack
          do ibit=1,2
          do itrack=1,max_track
            if(itrack_map(ibit,ihd,itrack) .ne. 
     >         itrack_map_vec(ibit,ihd,itrack,imap)) then
               if(kdebug_itras) then 
                 write(*,*) "mismatch at: ",itrack,ihd,ibit,imap," | ",
     >            itrack_map(ibit,ihd,itrack),
     >            itrack_map_vec(ibit,ihd,itrack,imap)
               endif
              goto 100
            endif 
          end do
          end do 
        end do
        goto 200   ! a match
100     continue
      end do

! No match.  Add it in.
      if(num_track_map .lt. max_track_map) then
         num_track_map=num_track_map+1
      else
        write(*,*) "Exceeded number of tracks maps!"
        write(*,*) "Change itras_cmn and Recompile itras.f"
        stop
      endif
      imap=num_track_map
! Copy itrack_knew into itrack_map_vec
      do ibit=1,2
      do ihd=1,max_headstack
      do itrack=1,max_track
        itrack_map_vec(ibit,ihd,itrack,imap)=itrack_map(ibit,ihd,itrack)
      end do
      end do
      end do           


200   continue     
      if(kdebug_itras) then 
        write(*,*) "Added map: ", imap
      endif
      istn_code_key(istn,icod)=imap
      itrack_map_key=imap 
     
      max_tracks(imap)=max_tracks_new
      num_tracks(imap)=num_tracks_new
  
      num_bits(imap)  =num_bits_new  
      num_head(imap)  =num_head_new
      num_pass(imap)  =num_pass_new

      if(kdebug_itras) then 
        write(*,*) "Mx_trk #trks #bits #pass #head"
        write(*,'(6i6)')  max_tracks_new,num_tracks_new,num_bits_new,
     &  num_head_new,num_pass_new
      endif

      return
      end

! ***********************************************************************
      subroutine itras_params(istn,icode,npass,ntracks,nhead,nbits)
      include 'itras_cmn.ftni'
! passed
      integer istn
      integer icode
! returned
      integer npass,ntracks,nhead,nbits
! local
      integer imap

      imap=istn_code_key(istn,icode)
      if(imap .eq. 0) then
         npass=0
         ntracks=0
         nhead=0
         nbits=0
!        write(*,*) "ITRAS_PARAMS: Invalid Station/Code pair ",istn,icode
        return
      endif

      npass=num_pass(imap)
      ntracks=num_tracks(imap)
      nhead=num_head(imap)
      nbits=num_bits(imap)
      return
      end
! **********************************************************************
      integer*4 function itras_magic(isb,ibit,ichn,ipass)
      include '../skdrincl/skparm.ftni'
! Return a unique number based on isb,ibit,ichn,ipass

      integer isb,ibit,ichn,ipass
      itras_magic =      isb-1   +
     >                 2*(ibit-1  +
     >                 2*(ichn-1  +
     >          max_chan*(ipass-1)))
      return
      end
! **********************************************************************
      subroutine itras_magic_2_sb_bit_chn_pass(imagic,isb,ibit,ichn,
     &    ipass)
! Based on on itras_magic, return isb,ibit,icn,ipass
! 
      include '../skdrincl/skparm.ftni'
      integer*4 imagic 
      integer isb,ibit,ichn,ipass
      integer*4 ind

      ind=imagic

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
      include 'itras_cmn.ftni'
      integer ihead,istn
      if(ihead .le. max_headstack .and. istn .le. max_stn) then
         kheaduse=khead(ihead,istn)
      endif
      return
      end
! *********************************************************
      subroutine init_itras()
      include 'itras_cmn.ftni'

      integer ihead
      integer istn,ifrq

      num_track_map=0
  
      do ihead=1,max_headstack
      do istn=1,max_stn
        khead(ihead,istn)=.false.
        do ifrq=1,max_frq
          istn_code_key(istn,ifrq)=0
        end do
      end do
      end do

      return
      end
