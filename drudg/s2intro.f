      SUBROUTINE S2INTRO
C This routine writes commands at the head of SNAP files
C for S2 systems.
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/skobs.ftni'
C History:
C 000509 C.Klatt New.
C Called by: SNAP

      INTEGER NCH,KERR,ibuf2(80),iblen
      integer ichmv,ichmv_ch ! functions

      iblen=128
      NCH = 1	
      CALL IFILL(IBUF2,1,IBLEN,32)
      NCH = ICHMV_ch(IBUF2,NCH,'user_info=1,label,station')
      CALL WRITF_ASC(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      CALL IFILL(IBUF2,1,IBLEN,32)

      NCH = 1	
      NCH = ICHMV_ch(IBUF2,NCH,'user_info=2,label,source')
      CALL WRITF_ASC(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      CALL IFILL(IBUF2,1,IBLEN,32)

      NCH = 1	
      NCH = ICHMV_ch(IBUF2,NCH,'user_info=3,label,experiment')
      CALL WRITF_ASC(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      CALL IFILL(IBUF2,1,IBLEN,32)

      NCH = 1	
      NCH = ICHMV_ch(IBUF2,NCH,'user_info=3,field,')
      NCH = ICHMV(IBUF2,NCH,LEXPER,1,8)
      CALL WRITF_ASC(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)
      RETURN
      END
