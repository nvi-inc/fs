      SUBROUTINE PROCINTR
C
C This routine writes out the header information for proc files.
C into lu_outfile.
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C History
C 970225 nrv New. Copied from snapintr.

C  LOCAL:
      integer*2 IBUF2(80),lnamep(6)
	integer iblen
      integer idummy,nch,kerr
      integer ichcm_ch,ichmv,ichmv_ch
C
      idummy = ichmv_ch(lnamep,1,'proc_library')
      CALL CRPRC(LU_OUTFILE,LNAMEP)
      iblen = 128
      IF (ichcm_ch(LEXPER,1,'        ').EQ.0)  THEN
        IDUMMY = ichmv_ch(LEXPER,1,'XXX     ')
      END IF
      CALL IFILL(IBUF2,1,iblen,32)
      nch = 0
      NCH = ichmv_ch(IBUF2,1,'" ')
      NCH = ICHMV(IBUF2,NCH,LEXPER,1,8)
      NCH = ICHMV(IBUF2,NCH+3,LSTNNA(1,ISTN),1,8)
      NCH = ICHMV(IBUF2,NCH+2,LPOCOD(ISTN),1,2)
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      CALL writf_asc_ch(LU_OUTFILE,kERR,'enddef')
C
      RETURN
      END

