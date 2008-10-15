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
      integer iline   ! counter for up to 3 lines with 5 freqs each
      integer iz   ! counts up to 5 freqs on a line
      integer ix,iy,idum
      integer ichmv

      iline = 0
      iz = 0
      do ix=1,nchan(istn,icod)
        if(mod(iz,5) .eq. 0) then
          cbuf= ' bbsynth = '
	  iy = 11 
        endif

	if (fr(ix).ne.0.0) then
	  call bbsyn(iy,ix,fr(ix))
	  iz=iz+1
	  if (mod(iz,5).eq.0) then ! line is full
	    iline = iline+1
            cbbcbuf(imode,iline)=cbuf(1:iy)
	    ibbclen(imode,iline) = iy
	    nbbcbuf(imode) = iline
	  else
            cbuf(iy:iy)=","
            iy=iy+1
	 end if
        end if
      end do
      return
      end

