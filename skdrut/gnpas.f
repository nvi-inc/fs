      SUBROUTINE gnpas(luscn,ierr,iserr)
C
C     GNPAS derives the number of sub-passes in each frequency code
C and checks for compatibility between track assignments and head
C subpasses.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
C
C  Input
      integer luscn ! for error messages
C  Output
      integer ierr ! non-zero if inconsistent track counts per pass
      integer iserr(max_stn) ! error by station

C  LOCAL VARIABLES:
      integer ip,ip2,is,it,it2,np,np2,j,k,i,l,itrk(max_pass),
     .ic1,maxp(max_frq),itr2(max_pass)
      integer ix,iprr,ipmax,ipma2,ic,m,nvc,ichcm_ch
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
C
C
C     1. For each code, go through all possible passes and add
C     up the total number of tracks used. 
C     Use itras(u/l,s/m,max_pass,max_chan,station,code)
C     Use ihddir(max_pass,station,code)
C
      ierr=0
      IF (NCODES.LE.0) RETURN
C
      DO  Ic=1,NCODES ! codes
        do is=1,nstatn
          if (nchan(is,ic).gt.0) then ! this station has this mode defined
          if (ichcm_ch(lstrec(1,is),1,'S2').eq.0) then ! S2
            npassf(is,ic)=1
          else ! not S2
            iserr(is)=0
            np=0
            np2=0
            DO  J=1,max_pass ! count sub-passes
              itrk(j)=0
              itr2(j)=0
              IT = 0
              it2=0
              do k=1,nchan(is,ic) ! channels
                do l=1,2 ! upper/lower
                  do m=1,2 ! sign/mag
                    if (itras(l,m,k,j,is,ic).ne.-99) it=it+1
                    if (itra2(l,m,k,j,is,ic).ne.-99) it2=it2+1 ! headstack 2
                  enddo
                END DO ! upper/lower
              enddo ! channels
              if (it.gt.0) then
                np=np+1
                if (np.le.max_pass) itrk(np)=it
              endif
              if (it2.gt.0) then
                np2=np2+1
                if (np2.le.max_pass) itr2(np2)=it2
              endif
            END DO  ! count sub-passes
            ipmax=0
            ipma2=0
            do j=1,max_pass ! check sub-passes
              if (ihddir(j,is,ic).gt.ipmax) ipmax=ihddir(j,is,ic)
              if (ihddi2(j,is,ic).gt.ipmax) ipma2=ihddi2(j,is,ic)
            enddo ! check sub-passes
            npassf(is,ic)=np ! must be the same for both headstacks 
            ntrakf(is,ic)=itrk(1)+itr2(1)
            if (np2.gt.0.and.np.ne.np2) then ! inconsistent between headstacks
              write(luscn,9907) lcode(ic),(lstnna(i,is),i=1,4)
9907          format('GNPAS07 - Inconsistent number of sub-passes ',
     .        'between headstacks 1 and 2 for ',a2,' at ', 4a2)
            endif
            if (itr2(1).gt.0.and.itrk(1).ne.itr2(1)) then ! inconsistent 
              write(luscn,9908) lcode(ic),(lstnna(i,is),i=1,4)
9908          format('GNPAS08 - Inconsistent number of tracks per pass'
     .        ,'between headstacks 1 and 2 for ',a2,' at ', 4a2)
            endif
            if (ipmax.ne.npassf(is,ic)) then ! inconsistent
              ierr=1
              iserr(is)=1
              write(luscn,9904) lcode(ic),(lstnna(i,is),i=1,4)
9904          format('GNPAS04 - Inconsistent number of sub-passes ',
     .        'in tracks/headpos for ',a2,' at ',4a2)
            endif
            j=1
            do while (j.lt.np.and.itrk(j).eq.itrk(j+1))
              j=j+1
            enddo
            if (itrk(1).eq.0.or.np.eq.0.or.j.lt.np.or.np.gt.max_pass) 
     .        then
              ierr=1
              if (itrk(1).eq.0.or.np.eq.0) then
                write(luscn,9903) lcode(ic),(lstnna(j,is),j=1,4)
9903            format('GNPAS03 - No passes found in track assignments '
     .          ,' for ',a2,', at ',4a2)
              endif
              if (j.lt.np.or.np.gt.max_pass) then
                write(luscn,9901) lcode(ic),(lstnna(j,is),j=1,4)
9901            format('GNPAS01 - Inconsistent pass/track assignments '
     .          ,' for ',a2,', at ',4a2)
              endif
            endif
          endif ! S2 or not
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
        if (ichcm_ch(lstrec(1,is),1,'S2').ne.0) then ! not for S2
        ic1=0
        do ic=1,ncodes ! codes
          if (nchan(is,ic).gt.0) then ! this station has this mode defined
          if (ic1.eq.0) ic1=ic ! first ic for t his station
          ip=0
          ip2=0
          do j=1,max_pass
            if (ihddir(j,is,ic).eq.1) ip=ip+1
            if (ihddi2(j,is,ic).eq.1) ip2=ip2+1
          enddo
          if (ip.eq.0) then
            ierr=1
            iserr(is)=1
            write(luscn,9902) lcode(ic),(lstnna(i,is),i=1,4)
9902        format('GNPAS02 - No passes found in $HEAD section ',
     .      'for ',a2,' at ',4a2)
          endif
          maxp(ic)=ip
          if (ip2.ne.0.and.ip.ne.ip2) then
            write(luscn,9909) lcode(ic),(lstnna(i,is),i=1,4)
9909        format('GNPAS09 - Inconsistent number of passes in $HEAD',
     .      ' between headstacks 1 and 2 for ',a2,' at ',4a2)
          endif
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
            write(luscn,9905) (lstnna(i,is),i=1,4)
9905        format('GNPAS05 - Warning: different frequency codes ',
     .      'in this experiment have different numbers of passes',
     .      ' at ',4a2)
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
            if (freqlo(nvc,is,ic).eq.0.0.or.
     .      ichcm_ch(lifinp(nvc,is,ic),1,'  ').eq.0) kmiss=.true.
          enddo
          if (kmiss) write(luscn,9906) lcode(ic),(lstnna(i,is),i=1,4)
9906      format('GNPAS06 - Warning: ',a2,' LO information missing ',
     .    'for ',4a2)
          endif ! defined
        enddo
      enddo

      RETURN
      END
