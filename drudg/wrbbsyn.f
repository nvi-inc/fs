	SUBROUTINE wrbbsyn(lu,iblen,squal,imode,icod)
C
C  wrbbsyn creates the bbsynth lines for VLBA pointing files.
C
C   HISTORY:
C     gag   900727 CREATED
C     gag   910513 Added parameter to nchanv.
C     nrv   930412 Implicit none
C
	INCLUDE 'skparm.ftni'
C
C  INPUT:
      integer lu,iblen,icod
	real*4 squal(14)
	integer imode  !1=qual1 2=qual2
C
C  OUTPUT: none
C
C     CALLED BY: VLBAT, VLBAH
C
C   COMMON BLOCKS USED
	include 'freqs.ftni'
	include 'drcom.ftni'
	include 'statn.ftni'
C
C  LOCAL VARIABLES
      integer ix,iy,iz,ierr
C
C  INITIALIZED
C

C  1. Write out bbsyn.

	iz = 0
	call char2hol(' bbsynth=',ibuf,1,9)
	iy = 10
	do ix=1,nvcs(istn,icod)
	  if (squal(ix).ne.0.0) then
	    call bbsyn(iy,ix,squal(ix))
	    iz=iz+1
	    if (iz.eq.5) then
		CALL writf_asc(LU,IERR,IBUF,iy/2)
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
	if (iz.ne.0) then
	  if (imode.eq.1) then
	    call char2hol(' !NEXT!',ibuf,iy-1,iy+6)
	    iy = iy + 6
	  else
	    call char2hol(' ',ibuf,iy-1,iy)
	  end if
	  CALL writf_asc(LU,IERR,IBUF,iy/2)
	  call ifill(ibuf,1,iblen,32)
	else if ((iz.eq.0).and.(imode.eq.1)) then
	  call ifill(ibuf,1,iblen,32)
	  call char2hol(' !NEXT!',ibuf,1,7)
	  call writf_asc(lu,ierr,ibuf,4)
	end if
C
	RETURN
	END

