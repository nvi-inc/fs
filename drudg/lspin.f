      SUBROUTINE LSPIN(iDIR,ISPM,ISPS,IBUF2,NCH)
C LSPIN  forms a buffer with the SNAP command FASTx=nnMmmS
C
      include '../skdrincl/skparm.ftni'
C
C Input:
      integer idir,ispm,isps,nch
	integer*2 IBUF2(ibuf_len)
C
C MODIFICATIONS - 880411 NRV DE-COMPC'D
C nrv 930407 implicit none
C 970721 nrv Replace LDIR in call with idir

	integer Z8000
        integer ic,idummy
        integer ichmv,ib2as,ichmv_ch ! functions
	DATA Z8000/Z'8000'/
C
      IDUMMY = ichmv_ch(IBUF2,1,'FAST')
      if (idir.eq.+1) IDUMMY = ICHMV_ch(IBUF2,5,'f')
      if (idir.eq.-1) IDUMMY = ICHMV_ch(IBUF2,5,'r')
      if (idir.eq.0) return
      IDUMMY = ichmv_ch(IBUF2,6,'=')
	IC=Z8000+2
      NCH = 7+IB2AS(ISPM,IBUF2,7,ic)
      NCH = ichmv_ch(IBUF2,NCH,'M')
      NCH = NCH + IB2AS(ISPS,IBUF2,NCH,ic)
      NCH = ichmv_ch(IBUF2,NCH,'S ')-1
      RETURN
      END
