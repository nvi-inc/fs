	SUBROUTINE vlbap(lu,icod,ierr)
C
C   This subroutine writes the header lines and creates
C   the track and bbsynth commands for the scan blocks
C   when writing a VLBA schedule.
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
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
C
C
C  INPUT:
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
	real mmaxv(14)   !synth/1000
	character*3 cs   !set character
	logical ksx      ! true for S/X frequencies
        logical k96      ! true if 9600 synth is in use
	real squal1(14), squal2(14) ! BBC freqs. grouped by sets
      integer nch,idum,ivcb,ix,iy,iz,ixy,nw,i,n,imode,j,k,ileft,im
      double precision fr
      integer ib2as,ichcm_ch,ir2as,ichmv_ch ! functions
C

	iblen = ibuf_len*2

C  NOTE: The header lines are written out for only the FIRST FREQUENCY
C        CODE encountered in the schedule.  If the code is changed
C        for some observations, this could be incorrect.

	nvset = ivix(icod,istn)
        imode=1


C ifchan = (n,IFchan(n)), ... where n=1 to nchan
	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'ifchan = ',9,idum,lifchan,4,imode)
	if (ierr.ne.0) then
	  write(luscn,9500)
9500    format(' VLBAH05 - Error writing ifchan section of header.')
	  ierr = 0
	end if

C sideband = (n,SB(n)), ... where n=1 to nchan

	call ifill(ibuf,1,iblen,32)
	call wrhead(lu,ierr,'sideband = ',11,idum,lsbv,4,imode)
	if (ierr.ne.0) then
	  write(luscn,9600)
9600    format(' VLBAH06 - Error writing sideband section of header.')
	  ierr = 0
	end if

C bbsynth = (n,abs[VCfreq(vc(n))-Synth(n))], ...
C       where n=1 to nchan for unswitched sequences

	do ix=1,nchanv(nvset) !calculate BBC frequencies
	  nvc = ivcv(nvset,ix)
	  synthv(ix) = abs(freqrf(nvc,icod) - synthf(nvset,ix))
	end do

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

C PCAL = 1MHz

	call ifill(ibuf,1,iblen,32)
	call char2hol('pcal = 1MHZ ',ibuf,1,12)
	call writf_asc(lu,ierr,ibuf,6)
C   These lines allow the use of the pcal extractors on the DS board.
C   If nchanv(nvset)=14 use these lines.
        if (nchanv(nvset).eq.14) then
C  call ifill(ibuf,1,iblen,32)
C         call char2hol('pcalxbit1=(1,S1),(2,S3),(3,S5),(4,S7),(5,S9),(6
C    .,S11),(7,S13),(8,S1)',ibuf,1,68)
C  call writf_asc(lu,ierr,ibuf,34)
C         call ifill(ibuf,1,iblen,32)
C         call char2hol('pcalxbit2=(1,S2),(2,S4),(3,S6),(4,S8),(5,S10),(
C    .6,S12),(7,S14),(8,S9)',ibuf,1,68)
C         call writf_asc(lu,ierr,ibuf,34)
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
C  call ifill(ibuf,1,iblen,32)
C         call char2hol('pcalxbit1=(1,S1),(2,S3),(3,S5),(4,S7),(5,S1),(6
C    .,S3),(7,S5),(8,S7)',ibuf,1,68)
C  call writf_asc(lu,ierr,ibuf,34)
C         call ifill(ibuf,1,iblen,32)
C         call char2hol('pcalxbit2=(1,S2),(2,S4),(3,S6),(4,S8),(5,S2),(6
C    .,S4),(7,S6),(8,S8)',ibuf,1,68)
C         call writf_asc(lu,ierr,ibuf,34)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxfreq1=(1,10),(2,10),(3,10),(4,10),(5,10),(
     .6,10),(7,10),(8,0)',ibuf,1,68)
          call writf_asc(lu,ierr,ibuf,34)
          call ifill(ibuf,1,iblen,32)
          call char2hol('pcalxfreq2=(1,10),(2,10),(3,10),(4,10),(5,10),(
     .6,10),(7,10),(8,0)',ibuf,1,68)
	  call writf_asc(lu,ierr,ibuf,34)
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

	RETURN
	END
