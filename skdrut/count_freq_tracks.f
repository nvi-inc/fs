      SUBROUTINE count_freq_tracks(cbnd,nbnd,luscn)
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'

! History
!  V1.00  2004Sep22, first version.
!  V1.01  2004Oct04, modified to include effect of fanout.
!

! functions
      integer itras
      integer iwhere_in_string_list

! passed
      character*2 cbnd(2)
      integer nbnd
      integer luscn
C
C  LOCAL VARIABLES
      integer ierr,ip,ic,i,iv,is,isub,iul
      integer ih
      character*3 cs
      integer itrk_tot
C
C  1. Count number of frequencies and the number of tracks being
C     recorded at each station on each frequency.
C
      ierr=0
      nbnd=0

      cbnd(1)=" "
      cbnd(2)=" "
      do ic=1,ncodes
        do is=1,nstatn
          nfreq(1,is,ic)=0
          nfreq(2,is,ic)=0
          do i=1,nchan(is,ic)
            iv=invcx(i,is,ic)
            if (iv.ne.0) then ! this channel is used
              isub=iwhere_in_string_list(cbnd,nbnd,csubvc(iv,is,ic))
              if(isub .eq. 0) then
                nbnd=nbnd+1
                if(nbnd .ge. 3) then
                  write(luscn,'(a,a,a)')
     >                  "Count_freq_tracks:  Too many bands. ",
     >                   ccode(ic), "ignored."
                  nbnd=nbnd-1
                  return
                endif
                cbnd(nbnd)=csubvc(iv,is,ic)
                isub=nbnd
              endif
              nfreq(isub,is,ic)=nfreq(isub,is,ic)+1 !count number of frequencies
              cs=cset(iv,is,ic)
              do iul=1,2
                ip=1
C               Full addition for sign bit
                do ih=1,max_headstack
                  if (itras(iul,1,ih,iv,ip,is,ic).ne.-99) then
                    if (cs.eq.'1,2'.or.cs(1:1).eq.' ') then ! both cycles
C                      All the data on un-switched tracks are used
                       trkn(isub,is,ic)=trkn(isub,is,ic)+1
                       ntrkn(isub,is,ic)=ntrkn(isub,is,ic)+1
                    else if (cs(1:1).eq.'1') then ! one cycle=switched
C                      Two-thirds of the data on a switched track are used
                       trkn(isub,is,ic)=trkn(isub,is,ic)+0.6667
                       ntrkn(isub,is,ic)=ntrkn(isub,is,ic)+1
                    endif
                  endif
C                 Add another 0.978 for magnitude bit
                  if (itras(iul,2,ih,iv,ip,is,ic).ne.-99) then
                    trkn(isub,is,ic)=trkn(isub,is,ic)+0.978
                    ntrkn(isub,is,ic)=ntrkn(isub,is,ic)+1
                  endif
                enddo
              end do
            endif
          enddo
! Issue warning.
          itrk_tot=(ntrkn(1,is,ic)+ntrkn(2,is,ic))*ifan(is,ic)
          if(itrk_tot .ne. 0) then
            if(cbarrel(is,ic) .ne. "NONE") then
              if(itrk_tot .ne. 8 .and. itrk_tot .ne. 16 .and.
     >           itrk_tot .ne. 32) then
                write(*,*)
     >             " Warning!!!  Barrel roll ",cbarrel(is,ic),
     >             " is not allowed for ", cstnna(is)
                write(*,*) "Number of tracks is ",itrk_tot
              endif
            endif
          endif
        enddo
      enddo

C  1.5 Calculate sample rate if not specified.

C
      do ic=1,ncodes
        if (samprate(ic).eq.0) samprate(ic)=2.0*vcband(1,1,ic)
      enddo

      RETURN
      END

