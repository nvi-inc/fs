      SUBROUTINE m3mode(istn,icode)

C  M3MODE looks at the track assignments and determines if they
C  correspond to any of the standard Mark3 modes.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'

C INPUT
      integer istn,icode
C OUTPUT
C     LMODE in common is modified with the Mk3 mode.
c LOCAL
      integer idum,ntra,i,j,k,l,m
      integer ichmv_ch
C History
C 020909 nrv If a station has all the tracks of a standard mode
C            plus some others, it should not be classified as a
C            standard mode.  Count tracks in itras and compare 
C            to 28.

C     itras(bit,sb,max_headstack,MAX_CHAN,MAX_subPASS,max_stn,max_frq)

C  Count the tracks
      ntra = 0
      do i=1,2 ! nbits
        do j=1,2 ! sideband
          do k=1,max_headstack
            do l=1,max_chan
              do m=1,max_subpass
                if (itras(i,j,k,l,m,istn,icode).ne.-99) ntra=ntra+1
              enddo
            enddo
          enddo
        enddo
      enddo

C  Check the tracks
      if ( itras(1,1,1, 1,1,istn,icode).eq.15 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 1 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq.17 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 3 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq.19 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq. 5 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq.21 .and.
     .     itras(1,1,1, 8,1,istn,icode).eq. 7 .and.
     .     itras(1,1,1, 9,1,istn,icode).eq.23 .and.
     .     itras(1,1,1,10,1,istn,icode).eq. 9 .and.
     .     itras(1,1,1,11,1,istn,icode).eq.25 .and.
     .     itras(1,1,1,12,1,istn,icode).eq.11 .and.
     .     itras(1,1,1,13,1,istn,icode).eq.27 .and.
     .     itras(1,1,1,14,1,istn,icode).eq.13 .and.
     .     itras(1,1,1, 1,2,istn,icode).eq.16 .and.
     .     itras(1,1,1, 2,2,istn,icode).eq. 2 .and.
     .     itras(1,1,1, 3,2,istn,icode).eq.18 .and.
     .     itras(1,1,1, 4,2,istn,icode).eq. 4 .and.
     .     itras(1,1,1, 5,2,istn,icode).eq.20 .and.
     .     itras(1,1,1, 6,2,istn,icode).eq. 6 .and.
     .     itras(1,1,1, 7,2,istn,icode).eq.22 .and.
     .     itras(1,1,1, 8,2,istn,icode).eq. 8 .and.
     .     itras(1,1,1, 9,2,istn,icode).eq.24 .and.
     .     itras(1,1,1,10,2,istn,icode).eq.10 .and.
     .     itras(1,1,1,11,2,istn,icode).eq.26 .and.
     .     itras(1,1,1,12,2,istn,icode).eq.12 .and.
     .     itras(1,1,1,13,2,istn,icode).eq.28 .and.
     .     itras(1,1,1,14,2,istn,icode).eq.14 .and.
     .     nchan(istn,icode).eq.14 .and.
     .     ntra.eq.28 .and.
     .     npassf(istn,icode).eq.2 ) then ! mode C 
        call ifill(lmode(1,istn,icode),1,8,oblank)
        idum = ichmv_ch(LMODE(1,istn,ICODE),1,'C') 
      endif ! mode C

      if ( itras(1,1,1, 1,1,istn,icode).eq. 1 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 2 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq. 3 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 4 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq. 5 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq. 6 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq. 7 .and.
     .     itras(1,1,1, 8,1,istn,icode).eq. 8 .and.
     .     itras(1,1,1, 9,1,istn,icode).eq. 9 .and.
     .     itras(1,1,1,10,1,istn,icode).eq.10 .and.
     .     itras(1,1,1,11,1,istn,icode).eq.11 .and.
     .     itras(1,1,1,12,1,istn,icode).eq.12 .and.
     .     itras(1,1,1,13,1,istn,icode).eq.13 .and.
     .     itras(1,1,1,14,1,istn,icode).eq.14 .and.
     .     itras(2,1,1, 1,1,istn,icode).eq.15 .and.
     .     itras(2,1,1, 2,1,istn,icode).eq.16 .and.
     .     itras(2,1,1, 3,1,istn,icode).eq.17 .and.
     .     itras(2,1,1, 4,1,istn,icode).eq.18 .and.
     .     itras(2,1,1, 5,1,istn,icode).eq.19 .and.
     .     itras(2,1,1, 6,1,istn,icode).eq.20 .and.
     .     itras(2,1,1, 7,1,istn,icode).eq.21 .and.
     .     itras(2,1,1, 8,1,istn,icode).eq.22 .and.
     .     itras(2,1,1, 9,1,istn,icode).eq.23 .and.
     .     itras(2,1,1,10,1,istn,icode).eq.24 .and.
     .     itras(2,1,1,11,1,istn,icode).eq.25 .and.
     .     itras(2,1,1,12,1,istn,icode).eq.26 .and.
     .     itras(2,1,1,13,1,istn,icode).eq.27 .and.
     .     itras(2,1,1,14,1,istn,icode).eq.28 .and.
     .     nchan(istn,icode).eq.28 .and.
     .     ntra.eq.28 .and.
     .     npassf(istn,icode).eq.1 ) then ! mode A 
        call ifill(lmode(1,istn,icode),1,8,oblank)
        idum = ichmv_ch(LMODE(1,istn,ICODE),1,'A') 
      endif ! mode A

      if ( itras(1,1,1, 1,1,istn,icode).eq. 1 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 3 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq. 5 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 7 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq. 9 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq.11 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq.13 .and.
     .     itras(2,1,1, 8,1,istn,icode).eq.15 .and.
     .     itras(2,1,1, 9,1,istn,icode).eq.17 .and.
     .     itras(2,1,1,10,1,istn,icode).eq.19 .and.
     .     itras(2,1,1,11,1,istn,icode).eq.21 .and.
     .     itras(2,1,1,12,1,istn,icode).eq.23 .and.
     .     itras(2,1,1,13,1,istn,icode).eq.25 .and.
     .     itras(2,1,1,14,1,istn,icode).eq.27 .and.
     .     itras(1,1,1, 1,2,istn,icode).eq. 2 .and.
     .     itras(1,1,1, 2,2,istn,icode).eq. 4 .and.
     .     itras(1,1,1, 3,2,istn,icode).eq. 6 .and.
     .     itras(1,1,1, 4,2,istn,icode).eq. 8 .and.
     .     itras(1,1,1, 5,2,istn,icode).eq.10 .and.
     .     itras(1,1,1, 6,2,istn,icode).eq.12 .and.
     .     itras(1,1,1, 7,2,istn,icode).eq.14 .and.
     .     itras(2,1,1, 8,2,istn,icode).eq.16 .and.
     .     itras(2,1,1, 9,2,istn,icode).eq.18 .and.
     .     itras(2,1,1,10,2,istn,icode).eq.20 .and.
     .     itras(2,1,1,11,2,istn,icode).eq.22 .and.
     .     itras(2,1,1,12,2,istn,icode).eq.24 .and.
     .     itras(2,1,1,13,2,istn,icode).eq.26 .and.
     .     itras(2,1,1,14,2,istn,icode).eq.28 .and.
     .     nchan(istn,icode).eq.14 .and.
     .     ntra.eq.28 .and.
     .     npassf(istn,icode).eq.2 ) then ! mode B 
        call ifill(lmode(1,istn,icode),1,8,oblank)
        idum = ichmv_ch(LMODE(1,istn,ICODE),1,'B') 
      endif ! mode B

      if ( itras(1,1,1, 1,1,istn,icode).eq. 1 .and.
     .     itras(1,1,1, 2,1,istn,icode).eq. 3 .and.
     .     itras(1,1,1, 3,1,istn,icode).eq. 5 .and.
     .     itras(1,1,1, 4,1,istn,icode).eq. 7 .and.
     .     itras(1,1,1, 5,1,istn,icode).eq. 9 .and.
     .     itras(1,1,1, 6,1,istn,icode).eq.11 .and.
     .     itras(1,1,1, 7,1,istn,icode).eq.13 .and.
     .     itras(1,1,1, 1,2,istn,icode).eq.15 .and.
     .     itras(1,1,1, 2,2,istn,icode).eq.17 .and.
     .     itras(1,1,1, 3,2,istn,icode).eq.19 .and.
     .     itras(1,1,1, 4,2,istn,icode).eq.21 .and.
     .     itras(1,1,1, 5,2,istn,icode).eq.23 .and.
     .     itras(1,1,1, 6,2,istn,icode).eq.25 .and.
     .     itras(1,1,1, 7,2,istn,icode).eq.27 .and.
     .     itras(1,1,1, 1,3,istn,icode).eq. 2 .and.
     .     itras(1,1,1, 2,3,istn,icode).eq. 4 .and.
     .     itras(1,1,1, 3,3,istn,icode).eq. 6 .and.
     .     itras(1,1,1, 4,3,istn,icode).eq. 8 .and.
     .     itras(1,1,1, 5,3,istn,icode).eq.10 .and.
     .     itras(1,1,1, 6,3,istn,icode).eq.12 .and.
     .     itras(1,1,1, 7,3,istn,icode).eq.14 .and.
     .     itras(1,1,1, 1,4,istn,icode).eq.16 .and.
     .     itras(1,1,1, 2,4,istn,icode).eq.18 .and.
     .     itras(1,1,1, 3,4,istn,icode).eq.20 .and.
     .     itras(1,1,1, 4,4,istn,icode).eq.22 .and.
     .     itras(1,1,1, 5,4,istn,icode).eq.24 .and.
     .     itras(1,1,1, 6,4,istn,icode).eq.26 .and.
     .     itras(1,1,1, 7,4,istn,icode).eq.28 .and.
     .     nchan(istn,icode).eq. 7 .and.
     .     ntra.eq.28 .and.
     .     npassf(istn,icode).eq.4 ) then ! mode E 
        call ifill(lmode(1,istn,icode),1,8,oblank)
        idum = ichmv_ch(LMODE(1,istn,ICODE),1,'E') 
      endif ! mode E

      return
      end
