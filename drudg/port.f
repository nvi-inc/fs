      SUBROUTINE PORT

C   This routine will change the printer output destination and
C   the printer type and the output width.

C  COMMON BLOCKS:
      INCLUDE 'skparm.ftni'
      INCLUDE 'drcom.ftni'
C
C  History:
C  901018 NRV Changed variable name, changed logic to leave port
C             set if user types <return>.
C  901205 NRV Moved width option in here from main program.
C  911127 NRV Added EPSON24 option
C  940725 nrv Add dos/ux option
C  950829 nrv linux version, copied from PC-DRUDG
C
C  Local:
	character*128 ctemp,ctemp2
	integer*2 itemp(10)
	integer trimlen
        integer nch,l,ierr,idummy,ichmv
C
C   A special type of external file is a non-disk device or unit
C   opened with one of the DOS reserved filenames: i.e.
C    lpt1, lpt2, lpt3, com1, com2, ... etc.
C

C  1.0  Read the input from user and set port appropriatly.

	l=trimlen(cprport)
	write(luscn,9100) cprport(1:l)
9100  format(' Printer output set to ',A,'.  Just enter ',
     .       'return if you do not wish to change,'/' else type new ',
     .       'file name or PRINT  ? ')

	call gtrsp(ibuf,25,luusr,nch)

	if (nch.gt.0) call hol2char(ibuf,1,nch,cprport)

C  2.0  Now get printer type.

	ierr=1
	l=trimlen(cprttyp)
	do while (ierr.ne.0)
	  write(luscn,9200) cprttyp(1:l)
9200    format(' Printer type set to ',A,'.  Just enter return ',
     .  'if you do not wish to change,'/' else type LASER, EPSON, '
     .  'EPSON24, or FILE  ? ')

	  call gtrsp(ibuf,15,luusr,nch)

	  if (nch.gt.0) then
	    idummy = ichmv(itemp,1,ibuf,1,nch)
	    call hol2upper(itemp,nch)
	    call hol2char(itemp,1,nch,ctemp)
	    if (ctemp.eq.'EPSON'.or.ctemp.eq.'LASER'
     .      .or.ctemp.eq.'FILE'.or.ctemp.eq.'EPSON24') then
		cprttyp = ctemp
		ierr=0
	    else
		write(luscn,9210)
9210        format(' Invalid printer type.  Only LASER, EPSON, '
     .      'EPSON24, or FILE allowed.  Try again.')
	    endif
	  else
	    ierr=0
	  endif
	enddo

C  3. Now get printer output width.

	ierr=1
	ctemp2 = 'FULL'
	if (iwidth.eq.80) ctemp2='NARROW'
	l=trimlen(ctemp2)
	do while (ierr.ne.0)
	  write(luscn,9300) ctemp2(1:l)
9300    format(' Output format set to ',a,'.  Just enter return ',
     .  'if you do not wish to change,'/' else enter FULL (full width',
     .  ' listing) or NARROW (less info, narrower format):  ')

	  call gtrsp(ibuf,15,luusr,nch)

	  if (nch.gt.0) then
	    idummy = ichmv(itemp,1,ibuf,1,nch)
	    call hol2upper(itemp,nch)
	    call hol2char(itemp,1,nch,ctemp)
	    if (ctemp.eq.'FULL') then
		iwidth = 137
		ierr=0
	    else if (ctemp.eq.'NARROW') then
		iwidth = 80
		ierr=0
	    else
		write(luscn,9310)
9310        format(' Invalid output width.  Only FULL or NARROW'
     .      ' allowed.  Try again.')
	    endif
	  else
	    ierr=0
	  endif
	enddo


      RETURN
      END
