	SUBROUTINE vlbah(istin,icod,lu,ierr)
C
C   This subroutine writes the header lines and creates
C   the track and bbsynth commands for the scan blocks
C   when writing a VLBA schedule.
C
	include 'skparm.ftni'
	include 'drcom.ftni'
	include 'statn.ftni'
	include 'freqs.ftni'
C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900720 CREATED
C     gag   901025  got rid of trailing blanks
C                   also got rid of trailing 0's in Synth line
C     gag   910513  Added parameter to nchanv and also changed parameters
C                   for the vlba common variables for multiple stations.
C     NRV   910524  Changed logic on writing BBSYN commands to create
C                   buffers and store in common.
C     NRv   921022  Add "program=" line
C     NRv   930412  implicit none
C     nrv   930708  Derive "nchan" as number of recorded tracks, for mode A
C                   and write out all 28 channels 
C     nrv   940114  Add "pcalxbit" and "pcalxfreq" commands per C. Walker
C     nrv   940707  Modify the above per Peggy for the POL version only
C     nrv   941122  Different pcalxbit and xfreq for 8-channel sequences,
C                   per Peggy
C     nrv   950628  For mode A, make nchanv=nchanv*2
C
C
C  INPUT:
	integer istin ! 5=VLBA terminal, 6=VLBA antenna
      integer lu,icod
C
C  OUTPUT:
      integer ierr
C
C   SUBROUTINES
C     CALLED BY: POINT
C     CALLED: ifill,char2hol,ichmv,writf_ascc,ib2as,wrhead,getqual,
C             bbsyn,ir2as
C
C  LOCAL VARIABLES
	integer iblen  !buffer length
	integer immax  !maximum syn number
	integer nvc    !video converter number
	real*4 mmaxv(14)   !synth/1000
	character*3 cs   !set character
	logical ksx      ! true for S/X frequencies
        logical k96      ! true if 9600 synth is in use
	real*4 squal1(14), squal2(14) ! BBC freqs. grouped by sets
        integer*2 ldum
      integer nch,idum,ivcb,ix,iy,iz,ixy,nw,i,n,imode,j,k,ileft,im
      real*8 fr
      integer jchar,ib2as,ichcm_ch,ir2as,ichmv,ichmv_ch ! functions
C

	iblen = ibuf_len*2

C  NOTE: The header lines are written out for only the FIRST FREQUENCY
C        CODE encountered in the schedule.  If the code is changed
C        for some observations, this could be incorrect.

	nvset = ivix(icod,istn)

C * comment with station name frequency code

	call ifill(ibuf,1,iblen,32)
	call char2hol('!*',ibuf,1,2)
	nch = ichmv(ibuf,4,lantna(1,istn),1,8)
	nch = ichmv(ibuf,nch+1,lnafrq(1,icod),1,8)
	call writf_asc(lu,ierr,ibuf,(nch+1)/2)

C program = experiment-name

        call char2hol('program = ',ibuf,1,10)
        idum = ichmv(ibuf,11,lexper,1,8)
        call writf_asc(lu,ierr,ibuf,9)

C nchan = number of "B" lines
C Actually nchan is the number of channels to be recorded.
C For Mode A, there will be twice as many as for any mode C.
C Can't really derive nchan unambiguously by simply
C counting the tracks assigned. Check i=1,2 for U,L and
C pass 1 only.

        nchanr = 0
        do i=1,2
          do k=1,14
            if (itras(i,1,k,icod).ne.-99) nchanr=nchanr+1
          enddo
        enddo
        imode=1
        if (nchanr.eq.28) imode=2

	call ifill(ibuf,1,iblen,32)
	call char2hol('nchan = ',ibuf,1,8)
C  Unless this is mode A, nchanv(nvset) will be correct.
C  For mode A, multiply by 2.
        if (jchar(lmode(icod),1).eq.ocapa) 
     .  idum = ib2as(16,ibuf,9,2)
        idum = ib2as(nchanv(nvset),ibuf,9,2)
        if (nchanr.eq.28) idum = ib2as(nchanr,ibuf,9,2)
	call writf_asc(lu,ierr,ibuf,5)

C format = MarkIII

	call ifill(ibuf,1,iblen,32)
	call char2hol('format = MARKIII',ibuf,1,16)
	call writf_asc(lu,ierr,ibuf,8)

C bits = (n,1) ... where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'bits = ',7,1,idum,ldum,1,imode)

C samplerate = 2*vcbandwidthM

	call ifill(ibuf,1,iblen,32)
	call char2hol('samplerate =  M ',ibuf,1,16)
	ivcb=2*vcband(icod)
	idum = ib2as(ivcb,ibuf,14,1)
	call writf_asc(lu,ierr,ibuf,8)

C period = (n,1), ...  where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'period = ',9,1,idum,ldum,1,imode)
	if (ierr.ne.0) then
	  write(luscn,9100)
9100    format(' VLBAH01 - Error writing period section of header.')
	  ierr = 0
	end if

C bbfilter = (n,vcbandwidth M), ...  where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	ivcb=vcband(1)
	call wrhead(lu,ierr,'bbfilter = ',11,ivcb,idum,ldum,2,imode)
	if (ierr.ne.0) then
	  write(luscn,9200)
9200    format(' VLBAH02 - Error writing bbfilter section of header.')
	  ierr = 0
	end if

C level = (n,-1), ...  where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'level = ',8,-1,idum,ldum,1,imode)
	if (ierr.ne.0) then
	  write(luscn,9300)
9300    format(' VLBAH03 - Error writing level section of header.')
	  ierr = 0
	end if

C baseband = (n,BBC#(n)), ... where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'baseband = ',11,idum,ibbcv,ldum,3,imode)
	if (ierr.ne.0) then
	  write(luscn,9400)
9400    format(' VLBAH04 - Error writing baseband section of header.')
	  ierr = 0
	end if

C ifchan = (n,IFchan(n)), ... where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'ifchan = ',9,idum,idum,lifchan,4,imode)
	if (ierr.ne.0) then
	  write(luscn,9500)
9500    format(' VLBAH05 - Error writing ifchan section of header.')
	  ierr = 0
	end if

C sideband = (n,SB(n)), ... where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'sideband = ',11,idum,idum,lsbv,4,imode)
	if (ierr.ne.0) then
	  write(luscn,9600)
9600    format(' VLBAH06 - Error writing sideband section of header.')
	  ierr = 0
	end if

C bbsynth = (n,abs[VCfreq(vc(n))-Synth(n))], ...
C       where n=1 to nchan for unswitched sequences
C (For switched sequences, include only channels that have Set=1,2.)
C bbsynth = (1,610.99),(2,650.99),(3,730.99),(4,970.99)
C bbsynth = (5,677.01),(6,662.01),(7,607.01),(8,597.01)
C For the switched R&D sequence:
C bbsynth = (1,612.99),(8,667.01),(9,679.01),(10,669.01),(14,554.01)

	do ix=1,nchanv(nvset) !calculate BBC frequencies
	  nvc = ivcv(nvset,ix)
	  synthv(ix) = abs(freqrf(nvc,icod) - synthf(nvset,ix))
	end do

	if (kswitch(nvset)) then ! set up arrays with freqs by mode
	  do ix=1,nchanv(nvset)
	    cs = csetv(nvset,ix)
	    if (cs.eq.'1,2') then
		squal1(ix) = 0.0
		squal2(ix) = 0.0
	    else
		if (cs(1:1).eq.'0') then
		   call getqual('1',ix,squal1)
		   call getqual('2',ix,squal2)
		else if (cs(1:1).eq.'1') then
		  squal1(ix) = synthv(ix)
		  call getqual('2',ix,squal2)
		else if (cs(1:1).eq.'2') then
		  squal2(ix) = synthv(ix)
		  call getqual('1',ix,squal1)
		end if
	    end if
	  end do
C       Create buffers with switched frequencies
	  call bbbuf(1,squal1)
	  call bbbuf(2,squal2)
	end if

C  Now write out the unswitched frequencies in the header
	call ifill(ibuf,1,iblen,32)
        ileft = o'100000'
	iz = 0 ! channel counter
	call char2hol('bbsynth = ',ibuf,1,10)
	iy=11 ! character counter within buffer
	do ix=1,nchanv(nvset)
	  cs = csetv(nvset,ix)
	  if (((kswitch(nvset)).and.(cs(1:3).eq.'1,2')).or.
     .    (.not.kswitch(nvset))) then
            do im=1,imode
              iy = ichmv_ch(ibuf,iy,'(')
	      iz = iz + 1
C             Use iz counter for mode A, imode=2
              if (imode.eq.1) iy = iy + ib2as(ix,ibuf,iy,ileft+2)
C             Use actual ix counter for "normal" modes
              if (imode.eq.2) iy = iy + ib2as(iz,ibuf,iy,ileft+2)
              iy = ichmv_ch(ibuf,iy,',')
              iy = iy + ir2as(synthv(ix),ibuf,iy,6,2)
              iy = ichmv_ch(ibuf,iy,')')
	      if (mod(iz,5).eq.0) then ! have 5 frequencies on the line
		call writf_asc(lu,ierr,ibuf,(iy+1)/2)
		call ifill(ibuf,1,iblen,32)
		call char2hol('bbsynth = ',ibuf,1,10)
		iy=11
	      else
		iy = ichmv_ch(ibuf,iy,',')
	      endif
            enddo
	  end if
	end do
	if (mod(iz,5).ne.0) then ! write out what's left on the line
	  iy = ichmv_ch(ibuf,iy-1,' ')
	  call writf_asc(lu,ierr,ibuf,(iy+1)/2)
	  call ifill(ibuf,1,iblen,32)
	end if

C Write out set 1 of BBC frequencies for setup

	do i=1,nbbcbuf(1)
	  call writf_asc(lu,ierr,ibbcbuf(1,1,i),(ibbclen(1,i)+1)/2)
	enddo

C Write out set 2 of BBCs as comments

	do i=1,nbbcbuf(2)
	  call char2hol('!*',ibuf,1,2)
	  n = ichmv(ibuf,4,ibbcbuf(1,2,i),1,ibbclen(2,i))+1
	  call writf_asc(lu,ierr,ibuf,n/2)
	enddo

C logging = special
        if (istin.eq.5) then
          call char2hol('logging = special ',ibuf,1,18)
          call writf_asc(lu,ierr,ibuf,9)
        endif

C  Following lines are written out only for VLBA antennas

	if (istin.eq.6) then !VLBA antennas
C
C fe = (1,13cm),(2,4cm),(3,13cm),(4,4cm) if any RF freqs are
C     between 8-9 or 2-3 GHz
C !* Don't know what the front end is ... for others

	call ifill(ibuf,1,iblen,32)
	ksx = .false.
	do ix=1,nchanv(nvset)
	  fr = freqrf(ivcv(nvset,ix),icod)
	  if ((fr.lt.9000.0.and.fr.gt.8000.0).or.
     .      (fr.lt.3000.0.and.fr.gt.2000.0)) ksx=.true.
	enddo
	if (ksx) then
	  call char2hol('fe = (1,13cm),(2,4cm),(3,13cm),(4,4cm)',ibuf,
     .                 1,38)
	  nw = 19
	else
	  call char2hol('!* fe = unknown front end ',ibuf,1,26)
	  nw = 13
	end if
	call writf_asc(lu,ierr,ibuf,nw)

C noise = (1,low-s),(2,low-s),(3,low-s),(4,low-s)   for all codes

	call char2hol('noise = (1,low-s),(2,low-s),(3,low-s),(4,low-s) '
     .              ,ibuf,1,48)
	call writf_asc(lu,ierr,ibuf,24)
	call ifill(ibuf,1,iblen,32)

C PCAL = 1MHz
	call ifill(ibuf,1,iblen,32)
	call char2hol('pcal = 1MHZ ',ibuf,1,12)
	call writf_asc(lu,ierr,ibuf,6)
C   These lines allow the use of the pcal extractors on the DS board.
C   If nchanv(nvset)=14 use these lines.
        if (nchanv(nvset).eq.14) then
	  call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxbit1=(1,S1),(2,S3),(3,S5),(4,S7),(5,S9),(6
     .,S11),(7,S13),(8,S1)',ibuf,1,68)
	  call writf_asc(lu,ierr,ibuf,34)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxbit2=(1,S2),(2,S4),(3,S6),(4,S8),(5,S10),(
     .6,S12),(7,S14),(8,S9)',ibuf,1,68)
          call writf_asc(lu,ierr,ibuf,34)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxfreq1=(1,10),(2,10),(3,10),(4,10),(5,10),(
     .6,10),(7,10),(8,0)',ibuf,1,68)
          call writf_asc(lu,ierr,ibuf,34)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxfreq2=(1,10),(2,10),(3,10),(4,10),(5,10),(
     .6,10),(7,10),(8,0)',ibuf,1,68)
	  call writf_asc(lu,ierr,ibuf,34)
C   If nchanv(nvset)=8 use these lines.
        else if (nchanv(nvset).eq.8) then
	  call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxbit1=(1,S1),(2,S3),(3,S5),(4,S7),(5,S1),(6
     .,S3),(7,S5),(8,S7)',ibuf,1,68)
	  call writf_asc(lu,ierr,ibuf,34)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxbit2=(1,S2),(2,S4),(3,S6),(4,S8),(5,S2),(6
     .,S4),(7,S6),(8,S8)',ibuf,1,68)
          call writf_asc(lu,ierr,ibuf,34)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxfreq1=(1,10),(2,10),(3,10),(4,10),(5,2010)
     .(6,2010),(7,2010),(8,2010) ',ibuf,1,78)
          call writf_asc(lu,ierr,ibuf,39)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxfreq2=(1,10),(2,10),(3,10),(4,10),(5,2010)
     .(6,2010),(7,2010),(8,2010) ',ibuf,1,78)
	  call writf_asc(lu,ierr,ibuf,39)
        endif

C synth = (m,Synth(m)/1000), ... where m=1 to nsynth and nsynth=
C         largest value of Syn#

	immax = isyn(nvset,1)
	do ix=2,nchanv(nvset)
	  if (immax.lt.isyn(nvset,ix)) then
	    immax = isyn(nvset,ix)
	  end if
	end do
	do ix=1,immax
	  iy = 1
	  do while (iy.le.nchanv(nvset))
	    if (ix.eq.isyn(nvset,iy)) then
		mmaxv(ix) = synthf(nvset,iy)/1000.0
		iy = nchanv(nvset)
	    end if
	    iy = iy + 1
	  end do
	end do

	call ifill(ibuf,1,iblen,32)
	call char2hol('synth = ',ibuf,1,8)
	iy = 9
        k96=.false.
	do ix=1,immax
	  call char2hol('(',ibuf,iy,iy+1)
	  iy = iy+1
	  if (ix.le.9) then
	    idum = ib2as(ix,ibuf,iy,1)
	    iy = iy + 1
	  else
	    idum = ib2as(ix,ibuf,iy,2)
	    iy = iy + 2
	  end if
	  call char2hol(',',ibuf,iy,iy+1)
	  iy = iy + 1
	  idum = ir2as(mmaxv(ix),ibuf,iy,6,4)
          if (ichcm_ch(ibuf,iy,'9.6').eq.0) k96=.true.
	  iy = iy + 6
	  ixy = 1
	  do while (ixy.eq.1)
	    if (ichcm_ch(ibuf,iy-1,'0').eq.0) then
		iy = iy - 1
	    else
		ixy = 2
	    end if
	  end do
	  call char2hol('),',ibuf,iy,iy+2)
	  iy = iy + 2
	  if (ix.eq.8) then
	    call char2hol(' ',ibuf,iy-1,iy)
	    call writf_asc(lu,ierr,ibuf,(iy+1)/2)
	    call ifill(ibuf,1,iblen,32)
	    call char2hol('synth = ',ibuf,1,8)
	    iy=9
	  end if
	end do
	if (immax.ne.8) then
	  call char2hol(' ',ibuf,iy-1,iy)
	  call writf_asc(lu,ierr,ibuf,(iy+1)/2)
	  call ifill(ibuf,1,iblen,32)
	end if

C ifdistr = (1,0),(2,0),(3,0),(4,0)   for all codes

	call char2hol('ifdistr = (1,0),(2,0),(3,0),(4,0) ',ibuf,1,34)
	call writf_asc(lu,ierr,ibuf,17)
	call ifill(ibuf,1,iblen,32)


C fexfer = (2,split)  for switched sequences only
C Change to check for the use of 9600 synthesizer to determine 
C if transfer switch is on.

C	if (kswitch(nvset)) then
        if (k96) then
	  call char2hol('fexfer = (2,split)',ibuf,1,18)
	  call writf_asc(lu,ierr,ibuf,9)
	  call ifill(ibuf,1,iblen,32)
	end if

C azcolim and elcolim lines - no longer needed per C. Walker

C     call char2hol('azcolim = 0.00  elcolim = 0.00',ibuf,1,30)
C     call writf_asc(lu,ierr,ibuf,15)
C     call ifill(ibuf,1,iblen,32)

C logging = standard

  	call char2hol('logging = standard ',ibuf,1,19)
	call writf_asc(lu,ierr,ibuf,9)

	endif !VLBA antennas

	RETURN
	END
