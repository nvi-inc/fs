	SUBROUTINE bbsyn(iy,ix,fr)
C
C  bbsyn appends the appropriate bbysnth to the buffer
C  for writing the bbsyn frequencies
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/freqs.ftni'
C
C   HISTORY:
C  WHO   WHEN   WHAT
C  gag   900809 CREATED
C  NRV   910524 Added frequency to calling sequence
C  nrv   930412 implicit none
C
C  INPUT:
	integer iy  ! location in buffer ibuf
	integer ix  ! video converter number
	real fr     ! BBC frequency
C
C  OUTPUT:
C
C     CALLED BY: vlbah
C     CALLED: char2hol, ib2as, ir2as
C
C  LOCAL
	integer Z8000
      integer ib2as,ir2as ! functions
C
C  INITIALIZED
	data Z8000/Z'8000'/
C

C  Form the information inside parenthesis in the buffer.

	call char2hol('(',ibuf,iy,iy+1)
	iy = iy+1

C      if (ix.le.9) then
	  iy = iy + ib2as(ix,ibuf,iy,Z8000+2)
C        iy = iy + 1
C      else
C        idum = ib2as(ix,ibuf,iy,2)
C        iy = iy + 2
C      end if

	call char2hol(',',ibuf,iy,iy+1)
	iy = iy + 1

C      if (fr.lt.1000.0) then
	  iy = iy + ir2as(fr,ibuf,iy,7,2)
C        iy = iy + 6
C      else
C        idum = ir2as(fr,ibuf,iy,7,2)
C        iy = iy + 7
C      end if

	call char2hol(')',ibuf,iy,iy+1)
	iy = iy + 1
C
	RETURN
	END
