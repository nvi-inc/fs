	subroutine gtshft(isshft,imshft,ihshft,idshft,itimn,
     .  itimo,ierr)

C  GTSHFT reads through the observations and shifts them until it finds
C  the first shifted observation that is later than the input time ITIMN.

      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'

C  On input:
C    ITIM - in common, holds the shifted time of the current
C           observation in IBUF
	integer*2 ITIMN(6) ! new time we're looking for
        integer*2 itimo(6) ! original time of the shifted obs
	integer isshft,imshft,ihshft,idshft

C  On output:
C    ierr - -1 if we hit the end of the schedule before finding
C              a shifted time later than ITIMN.
      integer ierr

C  Local:
Cinteger*4 ifbrk
      integer iblen,ifc,ilc,ic1,ic2,i,ilen,iy,id,ih,im,is,
     .inday,inhr,inmin,insec,idum
      integer jchar,ichmv,ias2b ! functions
	logical kearl
	integer Z24
	data Z24/Z'24'/


C 1. The current observation is already read into IBUF.
C    The shifted time of that observation is in ITIM.
C    Begin the loop by testing whether ITIM is earlier than ITIMN.

	iblen = ibuf_len*2
	    IFC = 1
	    ILC = 128 !hard code for now
	    DO I=1,5
		CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
		IF(IC1.EQ.0) THEN
		  WRITE(LUSCN,9760)
		  ierr=-1
		  RETURN
		ENDIF
	    end do
	    idum = ichmv(ibuf,ic1,itim,1,11)
	    IDUM = ICHMV(ITIMo,1,IBUF,IC1,11)

	do while (kearl(itim,itimn)) ! read/shift until itim>itimn
	  CALL IFILL(IBUF,1,iblen,32)
C  if (ifbrk().lt.0) then
c    ierr=-1
c    return
c  endif
	  CALL readf_asc(LU_INFILE,IERR,IBUF,ISKLEN,iLEN)
	  CALL INC(LU_INFILE,IERR)
	  IF(IERR.NE.0) THEN
	    WRITE(LUSCN,9740) IERR
9740      FORMAT(' GTSHFT01 - ERROR ',I5,' reading observation line')
	    RETURN
	  ENDIF
	  IF ((iLEN.eq.-1).or.(JCHAR(IBUF,1).eq.Z24)) then
	    iy=ias2b(itimn,1,2)
	    id=ias2b(itimn,3,3)
	    ih=ias2b(itimn,6,2)
	    im=ias2b(itimn,8,2)
	    is=ias2b(itimn,10,2)
	    write(luscn,9100) iy,id,ih,im,is
9100      format(' Shifted schedule does not include the requested ',
     .    'time:  ',i2,1x,i3,'-',i2.2,':',i2.2,':',i2.2)
	    ierr=-1
	    return
	  else
	    IFC = 1
	    ILC = iLEN*2
	    DO I=1,5
		CALL GTFLD(IBUF,IFC,ILC,IC1,IC2)
		IF(IC1.EQ.0) THEN
		  WRITE(LUSCN,9760)
9760          FORMAT(' SKDSHFT18 - FIELD error skipping to',
     .        ' start time')
		  ierr=-1
		  RETURN
		ENDIF
	    end do
C
	    IDUM = ICHMV(ITIM,1,IBUF,IC1,11)
	    IDUM = ICHMV(ITIMo,1,IBUF,IC1,11)
	    call tshft(itim,inday,inhr,inmin,insec,
     .    isshft,imshft,ihshft,idshft)
	    idum = ichmv(ibuf,ic1,itim,1,11)
	  endif ! EOF
	enddo ! read/shift until itim>itimn

	ierr=0
	return
	end
