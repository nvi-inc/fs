	SUBROUTINE wrtrack(idx,lu,iblen,icod)
C
C  wrtrack writes the track lines for VLBA pointing files.
C
C   HISTORY:
C   WHO   WHEN    WHAT
C   gag   900727  created
C   gag   901025  added NEXT writing to track line.
C   gag   910513  Added parameter to nchanv for multiple vlba stations.
C   nrv   930412  implicit none
C   nrv   930709  Fixed to write correct mode A tracks
C   nrv   950406  fixed to write correct mode E tracks
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
	integer idx,lu,iblen,icod
C
C     CALLED BY: VLBAT
C
C   COMMON BLOCKS USED
      include 'drcom.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
C
C  LOCAL VARIABLES
      integer ib,iy,ul,ichan,iassign,ierr,iprint,nch,idum,ileft
      integer ichmv_ch,ib2as ! functions
C
C  INITIALIZED
C

C  1. Set up tracks for forward or reverse
C    itras(2,2,28,14,max_frq)  ! track assignments
C       U,L and S,M
C       to be recorded on forward or reverse ub-asses
C       for each VC (1-14)
C       frequency

        ileft = o'100000'
        iy=0
	iprint = 0
	call ifill(ibuf,1,iblen,32)
	call char2hol('track=',ibuf,1,6)
	nch = 7
	do ichan=1,nvcs(istn,icod)  !channels
	  do ul=1,2  !Upper and lower
	    iassign = itras(ul,1,invcx(ichan,istn,icod),idx,istn,icod)
C  Note: for mode A there is no track assignment for pass 2, so
C  no tracks are written. But both u/l are assigned.
C  Note: for 2-bit sampling, the track for the magnitude is automatically
C  recorded as the next one in the stack.
C  Note: for fan-out, the next track(s) are automatically recorded on
C  the next one on the stack.
	    if (iassign.gt.-99) then  !if number
		iassign = iassign + 3 ! VLBA track numbers
                nch = ichmv_ch(ibuf,nch,'(')
		iprint = iprint + 1
                iy = iy+1
                nch = nch + ib2as(iy,ibuf,nch,ileft+2)
                nch = ichmv_ch(ibuf,nch,',')
                nch = nch + ib2as(iassign,ibuf,nch,ileft+2)
                nch = ichmv_ch(ibuf,nch,'),')
	    end if !if number
	  end do !Upper and lower
	  if (iprint.eq.8) then
	    if (iprint.eq.nvcs(istn,icod)) then
C               nch = ichmv(ibuf,nch-1,2h  ,1,2)
                nch = ichmv_ch(ibuf,nch-1,' !NEXT!')
	    else
                nch = ichmv_ch(ibuf,nch-1,'  ')
	    end if
	    CALL writf_asc(LU,IERR,IBUF,(nch+1)/2)
	    call ifill(ibuf,1,iblen,32)
	    iprint = 0
	    call char2hol('track=',ibuf,1,6)
	    nch = 7
	  end if
	end do !channels
	if (iprint.ne.0) then
          nch = ichmv_ch(ibuf,nch-1,' !NEXT!')
	  CALL writf_asc(LU,IERR,IBUF,(nch+1)/2)
	  call ifill(ibuf,1,iblen,32)
	end if
	if (iy.eq.0) then !didn't write any tracks, but need a NEXT
          nch = ichmv_ch(ibuf,1,' !NEXT!')
	  CALL writf_asc(LU,IERR,IBUF,(nch+1)/2)
	  call ifill(ibuf,1,iblen,32)
	end if
C
	RETURN
	END

