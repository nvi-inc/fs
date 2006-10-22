      SUBROUTINE CRPRC(LU,LNAMEP)
c      DIMENSION IBUF(20)
	integer*2 ibuf(20)
	character*40 cbuf
	equivalence (cbuf,ibuf)
	cbuf="DEFINE "
	nch=8
      IDUMMY = ichmv_ch(IBUF,1,'DEFINE  ')
	IDUMMY = ICHMV(IBUF,9,LNAMEP,1,12)
      IDUMMY = ichmv_ch(IBUF,23,'00000000000X')
       call hol2lower(ibuf,34)
	call writf_asc(LU,IERR,IBUF,(34)/2)
C
32767 RETURN
      END
