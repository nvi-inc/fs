      SUBROUTINE gnpas(luscn,ierr,iserr)
C
C     GNPAS derives the number of sub-passes in each frequency code
C and checks for compatibility between track assignments and head
C subpasses.
C     GNPAS also counts the number of total passes per tape MAXPAS. 
C  GNPAS also determines if it's a Mark3 mode and modifies LMODE.
C
C GNPAS should determine the superset of recorded channels
C and re-arrange the numbering and indexing for stations that
C are not going to record all channels. This situation is occurs
C for the CORE-1 sessions in which Tsukuba records 14 channels
C and the other stations record 16 channels.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'

      integer itras
C
C  Input
      integer luscn ! for error messages
C  Output
      integer ierr ! non-zero if inconsistent track counts per pass
      integer iserr(max_stn) ! error by station

C  LOCAL VARIABLES:
      integer ih,ip(max_headstack),is,it(max_headstack),
     .np(max_headstack),
     .j,k,l,itrk(max_subpass,max_headstack),
     .ic1,maxp(max_frq)
      integer ix,iprr,ipmax(max_headstack),ic,m,nvc,ichcm_ch
      logical kmiss
C
C     880310 NRV DE-COMPC'D
C     930225 nrv implicit none
C 951019 nrv New frequency code common variables, handles VLBA modes
C 951213 nrv More effective tracks for 2-bit sampling.
C 960208 nrv Don't count effective tracks here. Add check for
C            consistency between track assignments and head positions.
C 960209 nrv Add error return by station
C 960219 nrv Check for LOs present also.
C 960610 nrv Change loop to nchan instead of max_chan for counting tracks.
C 960817 nrv Skip track checks for S2
C 961101 nrv Skip checks if the mode is not defined for this station.
C 961107 nrv Skip ALL checks for undefined modes.
C 961112 nrv Set MAXPAS to the value for the first code for this station,
C            not for the first code.
C 961115 nrv If there is only 1 mode, IC1 would remain at zero!
C 970206 nrv Remove itra2, ihddi2 and add headstack index to all.
C 970206 nrv Change max_pass to max_subpass
C 980907 nrv Change max_subpass as an index into inddir to max_pass.
C 000905 nrv If the second headstack isn't used, don't check it. If
C            it is used, remember it.
C 001011 nrv Initialize number of headstacks found in this code.
C 010817 nrv Not for K4 either.
! 2003Jul25  JMG  Changed itras to be a function.
C
C
C     1. For each code, go through all possible passes and add
C     up the total number of tracks used. 
C     Use itras(u/l,s/m,head,max_subpass,max_chan,station,code)
C     Use ihddir(head,max_pass,station,code)
C
      ierr=0
      IF (NCODES.LE.0) RETURN
C
      DO  Ic=1,NCODES ! codes
        do is=1,nstatn
          if (nchan(is,ic).gt.0) then ! this station has this mode defined
          if (ichcm_ch(lstrec(1,is),1,'S2').eq.0) then ! S2
            npassf(is,ic)=1
          else if (ichcm_ch(lstrec(1,is),1,'K4').eq.0) then ! K4
            npassf(is,ic)=1
          else ! not S2 or K4
            iserr(is)=0
            do ih=1,max_headstack ! for each headstack
              np(ih)=0
              DO  J=1,max_subpass ! count sub-passes
                itrk(j,ih)=0
                IT(ih) = 0
                do k=1,nchan(is,ic) ! channels
                  do l=1,2 ! upper/lower
                    do m=1,2 ! sign/mag
                      if (itras(l,m,ih,k,j,is,ic).ne.-99) 
     .                    it(ih)=it(ih)+1
                    enddo
                  END DO ! upper/lower
                enddo ! channels
                if (it(ih).gt.0) then
                  np(ih)=np(ih)+1
                  if (np(ih).le.max_subpass) itrk(np(ih),ih)=it(ih)
                endif
              END DO  ! count sub-passes
              ipmax(ih)=0
              do j=1,max_pass ! check sub-passes
                if (ihddir(ih,j,is,ic).gt.ipmax(ih)) 
     .          ipmax(ih)=ihddir(ih,j,is,ic)
              enddo ! check sub-passes
              if (ih.eq.1) then ! set npassf and increment ntrakf
                npassf(is,ic)=np(ih) 
                ntrakf(is,ic)=ntrakf(is,ic)+itrk(np(ih),ih)
                nhstack(is,ic) = 1
              else ! must be the same for both headstacks 
                if (np(ih).eq.0) then ! one head
                  nhstack(is,ic) = 1
                else ! check second
                  nhstack(is,ic) = ih
                  if (np(ih).ne.npassf(is,ic)) then ! inconsistent
                    write(luscn,9907) lcode(ic),cstnna(is)
9907                format('GNPAS07 - Inconsistent number of ',
     .              'sub-passes between headstacks 1 and 2 for ',
     .              'code ',a2,' at ', a)
                  endif ! check for consistency
                  if (itrk(1,1).ne.itrk(1,ih)) then ! inconsistent 
                    write(luscn,9908) lcode(ic),cstnna(is)
9908                format('GNPAS08 - Inconsistent number of tracks ',
     .              'per pass between',
     .              ' headstacks 1 and 2 for code',a2,' at ', a)
                  endif
                endif ! one head/check second
              endif ! set/check
            enddo ! for each headstack
            if (nhstack(is,ic).gt.nheadstack(is)) then ! can't do it
              write(luscn,9910) cstnna(is),nheadstack(is),
     .        lcode(ic),nhstack(is,ic)
9910          format('GNPAS10 - Station ',a,' has only ',i1,
     .        'headstack but code ',a2,' uses ',i1,' headstacks.')
            endif ! can't do it
            if (ipmax(1).ne.npassf(is,ic)) then ! inconsistent
              ierr=1
              iserr(is)=1
              write(luscn,9904) lcode(ic),cstnna(is)
9904          format('GNPAS04 - Inconsistent number of sub-passes ',
     .        'between tracks and headpos for ',a2,' at ',a)
            endif
            j=1
            do while (j.lt.np(1).and.itrk(j,1).eq.itrk(j+1,1))
              j=j+1
            enddo
            if (itrk(1,1).eq.0.or.np(1).eq.0.or.j.lt.np(1).or.
     .        np(1).gt.max_subpass) then
              ierr=1
              if (itrk(1,1).eq.0.or.np(1).eq.0) then
                write(luscn,9903) lcode(ic),cstnna(is)
9903            format('GNPAS03 - No passes found in trck assignments '
     .          ,' for ',a2,', at ',a)
              endif
              if (j.lt.np(1).or.np(1).gt.max_subpass) then
                write(luscn,9901) lcode(ic),cstnna(is)
9901            format('GNPAS01 - Inconsistent pass/track assignments '
     .          ,' for ',a2,', at ',a)
              endif
            endif
          endif ! S2/K4 or not
          endif ! defined
        enddo ! stations
      END DO  ! codes

C
C  2. Now count up the number of passes, i.e. different head positions.
C     Look in ihddir and count the non-zero entries. Do this only for
C     frequency code 1 because "maxpas" is only dimensioned by station.
C     Check for different numbers of passes used in different frequency
C     codes--this should not be attempted in a single experiment. 

      do is=1,nstatn ! stations
        if (cstrec(is) .ne. 'S2' .and. cstrec(is)(1:2) .ne. 'K4') then
        ic1=0
        do ic=1,ncodes ! codes
          if (nchan(is,ic).gt.0) then ! this station has this mode defined
          if (ic1.eq.0) ic1=ic ! first ic for this station
          do ih=1,nhstack(is,ic) ! check each headstack in use
            ip(ih)=0
            do j=1,max_pass
              if (ihddir(ih,j,is,ic).eq.1) ip(ih)=ip(ih)+1
            enddo
            if (ip(ih).eq.0) then
              ierr=1
              iserr(is)=1
              write(luscn,9902) ih,lcode(ic),cstnna(is)
9902          format('GNPAS02 - No passes found in $HEAD section ',
     .        'for head ',i1,' for ',a2,' at ',a)
            endif
            if (ih.eq.1) then
              maxp(ic)=ip(ih)
            else
              if (ip(ih).gt.0.and.ip(ih).ne.ip(1)) then
                write(luscn,9909) lcode(ic),cstnna(is)
9909            format('GNPAS09 - Inconsistent number of passes in',
     .          ' $HEAD',
     .          ' between headstacks 1 and 2 for ',a2,' at ',a)
              endif
            endif
          enddo ! each headstack
          endif ! defined
        enddo ! codes
        if (ic1.gt.0) then ! some code is defined
          iprr=0
          do ic=1,ncodes
            if (nchan(is,ic).gt.0) then ! this station has this mode defined
              if (maxp(ic).ne.maxp(ic1)) iprr=1
            endif ! defined
          enddo
          if (iprr.ne.0) then
            ierr=1
            iserr(is)=1
            write(luscn,9905) cstnna(is)
9905        format('GNPAS05 - Warning: different frequency codes ',
     .      'in this experiment have different numbers of passes at ',a)
          endif
          maxpas(is)=maxp(ic1)
        endif ! some code is defined
        endif ! not for S2
      enddo ! stations
C
C 3. Check for LOs present and issue warning if not.

      do ic=1,ncodes
        do is=1,nstatn
          if (nchan(is,ic).gt.0) then ! this station has this mode defined
          kmiss=.false.
          do ix=1,nchan(is,ic)
            nvc=invcx(ix,is,ic)
            if (freqlo(nvc,is,ic).lt.0.0.or.
     .      ichcm_ch(lifinp(nvc,is,ic),1,'  ').eq.0) kmiss=.true.
          enddo
          if (kmiss) write(luscn,9906) lcode(ic),cstnna(is)
9906      format('GNPAS06 - Warning: ',a2,' LO information missing ',
     .    'for ',a)
          endif ! defined
        enddo
      enddo

C  Check for Mk3 modes and modify LMODE.
      do ic=1,ncodes
        do is=1,nstatn
          call m3mode(is,ic)
        enddo
      enddo

      RETURN
      END
