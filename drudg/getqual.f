	SUBROUTINE getqual(cql,ix,icod,squal)
C
C  getqual gets either qual 1 or qual 2 bbsynth depending
C  on cql.
C
C   COMMON BLOCKS USED
	include 'skparm.ftni'
	include 'drcom.ftni'
	include 'sourc.ftni'
	include 'statn.ftni'
	include 'freqs.ftni'
C
C   HISTORY:
C  WHO   WHEN   WHAT
C  gag   900806 CREATED
C  gag   910513 Added parameter to nchanv to handle multiple vlba stations.
C 951213 nrv Changes for new Mark IV/VLBA setup
C
C Called by: VLBAH
C
C  INPUT:
	character cql   ! what qual (set) number we want
	integer ix    ! the video converter
        integer icod ! freq code
C
C  OUTPUT:
	real*4 squal(14)
C
C
C   SUBROUTINES
C     CALLED BY: vlbah
C     CALLED:
C
C
C  LOCAL VARIABLES
	integer iy    ! counter
	character*3 cs  ! the set number
        logical kgot
C
C  INITIALIZED
C
C
C  This loop will compare the set number and BBC number
C  to get the correct bbsynth for the appropriate qual for the
C  video converter ix.

	iy = 1
        kgot=.false.
	do while (iy.le.nvcs(istn,icod).and..not.kgot)
	  cs = cset(iy,istn,icod)
	  if ((iy.ne.ix).and.((cs(1:1).eq.cql).or.(cs.eq.'1,2')).and.
     .      (invcx(ix,istn,icod).eq.invcx(iy,istn,icod))) then
		  squal(ix)=freqlo(iy,istn,icod)
            kgot=.true.
	  end if
	  iy = iy + 1
	end do
C
	RETURN
	END
