	SUBROUTINE getqual(cql,ix,icod,squal)
C
C  getqual gets either qual 1 or qual 2 bbsynth depending
C  on cql.
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
C
C   HISTORY:
C  WHO   WHEN   WHAT
C  gag   900806 CREATED
C  gag   910513 Added parameter to nchanv to handle multiple vlba stations.
C 951213 nrv Changes for new Mark IV/VLBA setup
C 960516 nrv Use IBBCX instead of INVCX
C
C Called by: VLBAH
C
C  INPUT:
	character cql   ! what qual (set) number we want
	integer ix    ! the video converter
        integer icod ! freq code
C
C  OUTPUT:
	real*4 squal(max_chan)
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
	do while (iy.le.nchan(istn,icod).and..not.kgot)
	  cs = cset(iy,istn,icod)
	  if ((iy.ne.ix).and.((cs(1:1).eq.cql).or.(cs.eq.'1,2')).and.
     .      (ibbcx(ix,istn,icod).eq.ibbcx(iy,istn,icod))) then
		  squal(ix)=abs(freqrf(iy,istn,icod)-freqlo(iy,istn,icod))
            kgot=.true.
	  end if
	  iy = iy + 1
	end do
C
	RETURN
	END
