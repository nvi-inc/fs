	subroutine bbbuf(imode,icod,fr)

C     BBBUF creates buffers that hold the lines with bbsynth commands
C     This routine is called only for switched sequences

      include '../skdrincl/skparm.ftni'

C INPUT:
        integer icod    ! frequency code index
	integer imode   ! group 1 or 2 of the switched frequencies
	real fr(14)   ! the frequencies to write, should be filled
C                       with appropriate frequencies for the mode

C COMMON
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'

C CALLED by: VLBAH

C HISTORY
C NRV 910524 created
C nrv 930407 implicit none

C LOCAL
	integer in   ! counter for up to 3 lines with 5 freqs each
	integer iz   ! counts up to 5 freqs on a line
      integer ix,iy,iblen,idum
      integer ichmv


	iblen=ibuf_len*2
	in = 0
	iz = 0
	call ifill(ibuf,1,iblen,32)
	call char2hol(' bbsynth=',ibuf,1,9)
	iy = 10
	do ix=1,nchan(istn,icod)
	  if (fr(ix).ne.0.0) then
	    call bbsyn(iy,ix,fr(ix))
	    iz=iz+1
	    if (iz.eq.5) then ! line is full
		in = in+1
		idum=ichmv(ibbcbuf(1,imode,in),1,ibuf,1,iy)
		ibbclen(imode,in) = iy
		nbbcbuf(imode) = in
		call ifill(ibuf,1,iblen,32)
		iz = 0
		call char2hol(' bbsynth=',ibuf,1,9)
		iy = 10
	    else
		call char2hol(',',ibuf,iy,iy+1)
		iy = iy + 1
	    end if
	  end if
	end do

	return
	end

