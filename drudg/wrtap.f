	SUBROUTINE wrtap(lspdir,ispin,ihead,lu,iwr,ktape,irec)
C
C  WRTAP writes the tape lines for the VLBA
C  pointing schedules.
C
C   HISTORY:
C     WHO   WHEN   WHAT
C     gag   900724 CREATED
c     gag   901025 added ktape logical for NEXT writing
C     nrv   930709 Now "ihead" is the actual head position in microns,
C                  removed the hard-coded array.
C
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
C
C  INPUT:
        integer*2 lspdir
	integer ispin,ihead,lu,iwr,irec
	logical ktape
C
C     CALLED BY: vlbat
C
C  LOCAL VARIABLES
        integer*2 ltape(23)
	integer idum,iln,ierr
      integer ib2as,ichmv,ichmv_ch ! functions

C  INITIALIZED:
	DATA ltape/'ta','pe','=(','1,','s0','00','00','0)','  ',
     .           'wr','it',
     .           'e=','(1',',0','00',') ','he','ad','=(','1,','00',
     .           '00',') '/
C
      
C
C     Encode the recorder number into the string
      idum = ib2as(irec,ltape,7,1)
      idum = ib2as(irec,ltape,26,1)
      idum = ib2as(irec,ltape,39,1)
      if (ispin.ne.0) then
          idum=ichmv(ltape, 9,LSPDIR,1,1)
C         idum = ib2as(ispin,ltape,10,3)
	  if (ispin.eq.330) then
	    idum = ichmv_ch(ltape,10,'REWIND)')
	  else
	    idum = ichmv_ch(ltape,10,'RUN)   ')
	  endif
      else
	  idum = ichmv_ch(ltape,9,'STOP)   ')
      end if

      if (iwr.eq.0) then
	  idum = ichmv_ch(ltape,28,'off)')
      else
	  idum = ichmv_ch(ltape,28,'on) ')
      end if

	Idum = ib2as(IHEAD,ltape,41,4)
	idum = ichmv(ibuf,1,ltape,1,46)
	iln = 23
	if (ktape) then
	  call char2hol('  !NEXT!',ibuf,46,54)
	  iln = 27
	end if
	CALL writf_asc(LU,IERR,ibuf,iln)

      RETURN
      END
