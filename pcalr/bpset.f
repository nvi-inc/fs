      subroutine bpset(ihold,ibypch,itrk,ksplit,itka,itkb,iskip)
C
C     This routine sets up IBYPAS and the A and B tracks
C     for the tape recorder, according to the mode specified
C     in the common variables IREPPC and IBYPPC.  Before
C     changing ITRAKA, ITRAKB and IBYPAS, uncheck the tape
C     recorder and remember the check value in IHOLD.
C     Also check if RAW and track not enabled, then don't do track.
C
      include '../include/fscom.i'
C
      logical ksplit
C
      call fs_get_icheck(icheck(18),18)
100   ihold = icheck(18)
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      itrakb = itrk
      call fs_set_itrakb(itrakb)
      ksplit = .false.
C      - uncheck tape recorder whilst changing tracks 
700   goto (701,702,702,704) ireppc+1 
701   ibyppc = ibypas 
      if (itrkpc(itrk).ge.1.and.itrkpc(itrk).le.28.and.ibyppc.gt.0) 
     . ksplit = .true.
      goto 705
702   ibypas = ibyppc 
      goto 705
704   ibypas = ibyppc 
      if (itrkpc(itrk).ge.1.and.itrkpc(itrk).le.28) ksplit = .true. 
705   ibypch = ibyppc 
      if (ksplit) then
        itraka = itrkpc(itrk) 
        call fs_set_itraka(itraka)
      endif
      call fs_get_itraka(itraka)
      itka = itraka 
      call fs_get_itrakb(itrakb)
      itkb = itrakb 
      if (ibypch.eq.0.and.itrken(itrk).eq.0) iskip = -1 

      return
      end 
