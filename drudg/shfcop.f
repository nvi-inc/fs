	subroutine shfcop(isshft,imshft,ihshft,idshft,ilen,
     .id1,ih1,im1,nhshft,ierr)

C  SHFCOP shifts and copies observations.
C 910911 NRV Changed .gt. to .ge. test for number of hours
C 930412 nrv implicit none

C  Common:
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C  Input:
      integer id1,ih1,im1,isshft,imshft,ihshft,idshft,ilen,
     .nhshft
C  id1,ih1,im1 - starting day,hour,min of the shifted schedule
C  nhshft - number of hours required in the shifted schedule
C  xxshft - shift time

C Output:
      integer ierr

C  Local:
      integer iblen,idnow,ihnow,imnow,ifc,ilc,i,ic1,ic2,idum,
     .inday,inhr,inmin,insec
	logical kdone
Cinteger*4 ifbrk
	integer Z24
      integer ias2b,jchar,ichmv,nhdif ! function
	data Z24/Z'24'/

C  1.  IBUF and ITIM already contain the first shifted observation.
C   The main loop writes out the current line, already shifted.
C   Then, read an observation line and shift it.

	iblen = ibuf_len*2

	kdone = .false.
	do while (.not.kdone)
C  if (ifbrk().lt.0) then
C    ierr=-1
C    return
C  endif
	  idnow = ias2b(itim,3,3)
	  ihnow = ias2b(itim,6,2)
	  imnow = ias2b(itim,8,2)
	  CALL writf_asc(LU_OUTFILE,IERR,IBUF,iLEN)
	  CALL INC(LU_OUTFILE,IERR)
	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9830) IERR
9830      FORMAT(' SKDSHFT22 - ERROR ',I5,' writing shifted ',
     .    'observation line.')
	    ierr=-1
	    RETURN
	  ENDIF

	  CALL IFILL(IBUF,1,iblen,32)
	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	  CALL INC(LU_INFILE,IERR)
	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9810) IERR
9810      FORMAT(' SHFCOP20 - ERROR ',I5,' reading observation.')
	    ierr=-1
	    RETURN
	  ENDIF
C
	  if ((iLEN.eq.-1).or.(JCHAR(IBUF,1).eq.Z24).or.(nhdif(idnow,
     .  ihnow,imnow,id1,ih1,im1).ge.nhshft)) then
	    kdone = .true.
	  else
	    IFC = 1
	    ILC = iLEN*2
	    DO I=1,5
		CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
		IF(IC1.EQ.0) THEN
		  WRITE(LUSCN,9820)
9820          FORMAT(' SHFCOP21 - FIELD error skipping to start time')
		  ierr=-1
		  RETURN
		ENDIF
	    end do
C
	    IDUM = ICHMV(ITIM,1,IBUF,IC1,11)
	    CALL TSHFT(ITIM,INDAY,INHR,INMIN,INSEC,
     .         ISSHFT,IMSHFT,IHSHFT,IDSHFT)
	    idum = ichmv(ibuf,ic1,itim,1,11)
	  end if
	end do

	ierr=0
	return
	end
