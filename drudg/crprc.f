      SUBROUTINE CRPRC(LU,LNAMEP)
c      DIMENSION IBUF(20)
	integer*2 ibuf(20)
	INTEGER Z20
	DATA Z20/Z'20'/
	CALL IFILL(IBUF,1,40,Z20)
      IDUMMY = ichmv_ch(IBUF,1,'DEFINE  ')
	IDUMMY = ICHMV(IBUF,9,LNAMEP,1,12)
      IDUMMY = ichmv_ch(IBUF,23,'00000000000X')
       call hol2lower(ibuf,34)
	call writf_asc(LU,IERR,IBUF,(34)/2)
      call inc(LU,IERR)
C
32767 RETURN
      END
