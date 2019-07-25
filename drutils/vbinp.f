	SUBROUTINE VBINP(IBUF,ILEN,LU,IERR)

C     READ A VLBA ENTRY
C
C     This routine reads and decodes one line in the $VLBA section.
C     Called in a loop to get all values in freqs.for filled in.
C
C  CALLED BY:  SREAD
C
	 INCLUDE 'skparm.ftni'
C
C  INPUT:
	integer*2 IBUF(*)
        integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUF in WORDS
C     LU - unit for error messages
C
C  OUTPUT:
      integer ierr
C     IERR - error number
C
	 INCLUDE 'freqs.ftni'
	 INCLUDE 'statn.ftni'
C
C  LOCAL:
C       integer ITRK(2,28)
C       integer IP(14)
	INTEGER*2 lfr(4),lst(4)
	INTEGER iv,ib,itype,i,ncv,istx,ifrx
	character*3 cs
	real*4 sy
	INTEGER is
        integer*2 ls,li
	logical kmatch
        integer jchar,ichcm ! functions
C
C  History
C  WHEN    WHO  WHAT
C  900716  GAG  created, copied from frinp
C  910513  gag  Added logic to handle multiple vlba stations using common
C               variable ivlballn.
C  910524  NRV  Modified with new indices.  Changed some logic.
C  930225  nrv  implicit none
C
C
C  1. Find out what type of entry this is.  Decode as appropriate.
C
	ITYPE=0
	IF (JCHAR(IBUF,1).EQ.OCAPB) ITYPE=1 ! B
	IF (JCHAR(IBUF,1).EQ.OCAPL) ITYPE=2 ! L
	IF (ITYPE.EQ.2) CALL UNPVL(IBUF(2),ILEN-1,IERR,
     .                lst,lfr)
	IF (ITYPE.EQ.1) CALL UNPVB(IBUF(2),ILEN-1,IERR,
     .         iv,ib,cs,sy,is,ls,li)

	IF  (IERR.NE.0) THEN
	  IERR = -(IERR+100)
	  write(lu,9100) ierr,(ibuf(i),i=2,ilen)
9100    format('VBINP01 - Error in field ',I3,' of:'/40a2)
	  RETURN
	END IF
C
C
C  2. Now decide what to do with this information.
C     The "B" lines are channel entries.  We assume there
C     was already some "L" entries so that nvset is set.
C
	IF (ITYPE.EQ.1) THEN  ! B lines
	  ncv = nchanv(nvset)+1
	  nchanv(nvset) = ncv
	  ivcv(nvset,ncv) = iv
	  ibbcv(nvset,ncv) = ib
	  csetv(nvset,ncv) = cs
	  if (cs(1:1).ne.'0')  kswitch(nvset) = .true.
	  synthf(nvset,ncv) = sy
	  isyn(nvset,ncv) = is
	  lsbv(nvset,ncv) = ls
	  lifchan(nvset,ncv) = li
	  clast = 'B'
C
C  3. Next, "L" lines for station information.
C
	else IF (ITYPE.EQ.2) THEN  ! L lines
	  if (clast.ne.'L') then !first of a group of L lines
	    nvset = nvset+1
	  endif
	  i = 1
	  kmatch=.false.
	  do while (i.le.nstatn.and..not.kmatch)
	    if(ichcm(lst,1,lantna(1,i),1,8).eq.0) then
		kmatch=.true.
		istx = i
	    end if
	    i=i+1
	  end do
	  if (.not.kmatch) then
	    write(lu,9200) lst
9200      format('VBINP02 - Antenna name ',4A2,' not in station',
     .           ' list.')
	    return
	  end if

	  i = 1
	  kmatch=.false.
	  do while (i.le.ncodes.and..not.kmatch)
	    if(ichcm(lfr,1,lnafrq(1,i),1,8).eq.0) then
		kmatch=.true.
		ifrx = i
	    end if
	    i = i + 1
	  end do
	  if (.not.kmatch) then
	    write(lu,9300) lfr
9300      format('VBINP03 - Sequence name ',4A2,' not in ',
     .           'schedule.')
	    return
	  end if
C  Store frequency and station indices, increment number of sets.
	  ivix(ifrx,istx) = nvset
	  clast = 'L'
	end if ! B or L line
C
	RETURN
	END
