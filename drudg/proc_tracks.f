      subroutine proc_tracks(icode,num_tracks_rec_mk5)
      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

! passed
      integer icode
      integer num_tracks_rec_mk5        !how many Mk5Tracks?

! History
! 2007Jul13 JMGipson. Separated from procs.f

! functions
      integer mcoma     !lnfch stuff
      integer ib2as

! local
      integer izero
      integer ihead
      integer i,j       !loop indices
      logical kgrp0,kgrp1,kgrp2,kgrp3   !groups of tracks.
      logical kgrp4,kgrp5,kgrp6,kgrp7

      integer NumTracks         !Number of tracks used
      integer nch               !character counter
      integer z8000

      data Z8000/Z'8000'/

      izero=0

! Output Mark5B  recorder stuff.    
      if(km5rack.or.kv5rack.or.kdbbc_rack.or.km5b.or. knorack) then 
        call proc_disk_tracks(lu_outfile,istn,icode,
     >                  kignore_mark5b_bad_mask)
        return
      endif

! Write out the proc tracks command.

      nch=0
      if (km5A) then
        if(KM5APigWire(irec).and.km4form) then
          if(num_tracks_rec_mk5 .eq. 8) then   !map to 2nd headstack
            write(lu_outfile,'(a)') "tracks=v4"
          else if(num_tracks_rec_mk5 .eq. 16) then
            write(lu_outfile,'(a)') "tracks=v4,v6"
          else if(num_tracks_rec_mk5 .eq. 32) then
            write(lu_outfile,'(a)') "tracks=v4,v5,v6,v7"
          else
            writE(*,*) "Proc_track error: Should never get here!"
            write(*,*) "email: john.m.gipson@nasa.gov"
            stop            
          endif
        else
          if(num_tracks_rec_mk5 .eq. 8) then
             write(lu_outfile,'(a)') "tracks=v0"
          else if(num_tracks_rec_mk5 .eq. 16) then
             write(lu_outfile,'(a)') "tracks=v0,v2"
          else if(num_tracks_rec_mk5 .eq. 32) then
             write(lu_outfile,'(a)') "tracks=v0,v1,v2,v3"
          else if(num_tracks_rec_mk5 .eq. 64) then
            write(lu_outfile,'(a)') "tracks=v0,v1,v2,v3,v4,v5,v6,v7"
          endif
        endif
      else if((kvrack.or. km4form).and.
     .       (.not.kpiggy_km3mode.or.klsblo.or.
     .       ((km3ac.or.km3be).and.k8bbc)) ) then
! Makeporary copy of track table to use in determining if a track is used.
        numTracks=0
        do i=1,max_track
          do j=1,2
            itrk2(i,j)=itrk(i,j)
            if(itrk2(i,j).ne.0) NumTracks=NumTracks+1     !calculate #tracks
          end do
        end do

! Enable extra tracks for Mark5A modes.
        if(km5Arec(irec).or. KM5A_piggy.or. KM5APigWire(irec)) then   !For Mark5A recording, may need to remap tracks.
          if(NumTracks .le. 8) then
            NumTracks=8
          elseif(Numtracks .le. 16) then
            NumTracks=16
          elseif(NumTracks .le. 32) then
            NumTracks=32
          else
            NumTracks=64
          endif
          if(KM5A_piggy .or. KM5APigWire(irec)) then
            if(km4form) then
              ihead=2     !tracks mapped to 2nd head for km4.
            else
              ihead=1     !tracks mapped to first head.
            endif
!Clear appropriate headstack.
            if(KM5APigWire(irec)) then
              call iFill4(itrk2(1,ihead),Max_track,izero)
            endif
! And make the appropriate tracks active.
            if(NumTracks .le. 16) then
              do i=1,NumTracks
                itrk2(2*i,ihead)=1   !make even tracks active.
              end do
            else if(NumTracks .eq. 32) then
              do i=2,33             !Fill tracks 2-33
                itrk2(i,ihead)=1
              end do
            endif
          else if(KM5Arec(irec)) then
! clear track array.
            call iFill4(itrk2(1,1),Max_track,izero)
            call iFill4(itrk2(1,2),Max_track,izero)
! and refill it.
            if(NumTracks .le. 16) then
              do i=1,NumTracks
                itrk2(2*i,1)=1
              end do
            else if(NumTracks .eq. 32) then
              do i=2,33
                itrk2(i,1)=1
              end do
            else if(NumTracks .eq. 64) then
              do i=2,33
                itrk2(i,1)=1
                itrk2(i,2)=1             !this can only happen with 2 headstacks.
              end do
            endif
          endif   !KM5Arec
! Enable extra tracks for Mark5A modes.
        else if(KM5P_piggy) then
          do i=1,max_track
            if(km4form) then
              itrk2(i,2)=itrk(i,1)  !map to second headstack.
            else
!             itrk2(i,1)=itrk(i,1) Taken care of above.
           endif
          end do
        endif

! For Mark4P or Mark5P Piggyback, may want to dupicate tracks.
! This is done because we always record 32 tracks and this adds some redundancy.
! Also, need to have one of the 8 bytes completely full for disck check to work.
        if(KM5P_Piggy .or. KM5Prec(irec)) then
          if(KM5P_piggy.and.km4form) then
            ihead=2
          else
            ihead=1
          endif
          do i=2,32,2         !double up tracks if we need to.
             if(itrk2(i,ihead) .eq. 1) then
                itrk2(i+1,ihead)=1            !set it if it is not set.
             else if(itrk2(i+1,1) .eq. 1) then
                itrk2(i, ihead)=1
             endif
          end do
          kgrp0=.true.     !See if any byte of the 32 is full.
          kgrp1=.true.     !This is required for Mark5P disck_check to work.
          kgrp2=.true.
          kgrp3=.true.
          do i=2,9
            if(itrk2(i,   ihead) .ne. 1) kgrp0=.false.
            if(itrk2(i+ 8,ihead) .ne. 1) kgrp1=.false.
            if(itrk2(i+16,ihead) .ne. 1) kgrp2=.false.
            if(itrk2(i+24,ihead) .ne. 1) kgrp3=.false.
          end do
          if(.not.(kgrp0.or.kgrp1.or.kgrp2.or.kgrp3)) then
              write(luscn,'(1x,a)')  "**** Warning! PROCS: Mark5P."//
     >            "No full byte after duplicating"
              write(luscn,'("Set: ",4(8i1,1x))')(itrk2(i,1),i=2,33)
          endif
        endif

C           use second headstack for Mk5
! head1
! ...find marked groups and zero them in 2nd copy of track table, put "V0" etc as appropriate.
      cbuf="tracks="
      nch=8
! first try to pick up VLBA groups.
      call ChkGrpAndWrite(itrk2, 2,16,1,'v0',kgrp0,cbuf,nch)
      call ChkGrpAndWrite(itrk2, 3,17,1,'v1',kgrp1,cbuf,nch)
      call ChkGrpAndWrite(itrk2,18,32,1,'v2',kgrp2,cbuf,nch)
      call ChkGrpAndWrite(itrk2,19,33,1,'v3',kgrp3,cbuf,nch)

! if this doesn't work, pick up Mark4 groups.
      if(.not. kgrp0)
     >    call ChkGrpAndWrite(itrk2, 4,16,1,'m0',kgrp0,cbuf,nch)
      if(.not.kgrp1)
     >    call ChkGrpAndWrite(itrk2, 5,17,1,'m1',kgrp1,cbuf,nch)
      if(.not.kgrp2)
     >    call ChkGrpAndWrite(itrk2,18,30,1,'m2',kgrp2,cbuf,nch)
      if(.not.kgrp3)
     >    call ChkGrpAndWrite(itrk2,19,31,1,'m3',kgrp3,cbuf,nch)
! head2
      if(km4form) then
         call ChkGrpAndWrite(itrk2, 2,16,2,'v4', kgrp4,cbuf,nch)
         call ChkGrpAndWrite(itrk2, 3,17,2,'v5', kgrp5,cbuf,nch)
         call ChkGrpAndWrite(itrk2,18,32,2,'v6', kgrp6,cbuf,nch)
         call ChkGrpAndWrite(itrk2,19,33,2,'v7', kgrp7,cbuf,nch)
         if(.not.kgrp4)
     >     call ChkGrpAndWrite(itrk2, 4,16,2,'m4',kgrp4,cbuf,nch)
         if(.not.kgrp5)
     >     call ChkGrpAndWrite(itrk2,5,17,2,'m5',kgrp5,cbuf,nch)
         if(.not.kgrp6)
     >     call ChkGrpAndWrite(itrk2,18,30,2,'m6',kgrp6,cbuf,nch)
         if(.not.kgrp7)
     >     call ChkGrpAndWrite(itrk2,19,31,2,'m7',kgrp7,cbuf,nch)
      endif

      if(nch .ne. 8) then
        write(lu_outfile,'(a)') cbuf(1:nch-2)  !skip last comma.
        nch=0
      endif

C  Now pick up leftover tracks that didn't appear in a whole group
C  and list each one separately.
        do ihead=1,Max_headstack
          if(ihead .eq. 1 .or. km4form) then
            do i=2,33
              if(nch .eq. 0) then
                cbuf="tracks=*,"
                nch=10
              endif

              if(itrk2(i,ihead) .eq. 1) then
                nch = nch + ib2as(i+(ihead-1)*100,ibuf,nch,Z8000+3)
                nch = MCOMA(IBUF,nch)
              endif

              if(nch .ge. 60) then
                write(lu_outfile,'(a)') cbuf(1:nch-2)  !skip last comma.
                nch=0
              endif
            end do
          endif
          if(nch .gt. 10 .and. nch .ne. 0) then    !write out everything on first headstack.
             write(lu_outfile,'(a)') cbuf(1:nch-2)     !skip last comma.
             nch=0
          endif
        end do

        if(nch .gt. 10 .and .nch .ne. 0) then
           write(lu_outfile,'(a)') cbuf(1:nch-2)   !skip last comma.
           nch=0
        endif
      endif ! kvrack.or.km4rack.or.kv4rack and .not. km3mode

      return
      end


