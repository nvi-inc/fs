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
C 990512 nrv Add rack and rec types to call so that they can be
C            printed in the proc library header.
C 990520 nrv Add FS and drudg versions to the comment headers.
C 990803 nrv Merge FS and drudg lines and reformat.
C 991101 nrv k*rec variables are dimensioned (2) and messages
C            show recorder A or B.
C 991210 nrv Write equipment name from common.
C 991214 nrv Remove calling parameters, not nneeded.

C Input
C  LOCAL:
      integer*2 IBUF2(80),lnamep(6)
      integer iblen
      integer idummy,nch,kerr
      integer ichcm_ch,ichmv,ichmv_ch,ib2as
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

      CALL IFILL(IBUF2,1,iblen,32)
      nch=ichmv_ch(ibuf2,1,'" drudg version ')
      nch=ichmv_ch(ibuf2,nch,cversion(1:6))
      nch=ichmv_ch(ibuf2,nch,' compiled under FS ')
      idummy=iVerMajor_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      nch = ichmv_ch(ibuf2,nch,'.')
      idummy=iVerMinor_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      nch = ichmv_ch(ibuf2,nch,'.')
      idummy=iVerPatch_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)

      CALL IFILL(IBUF2,1,iblen,32)
      nch = 0
      NCH = ichmv_ch(IBUF2,1,'"< ')
      nch = ichmv(ibuf2,nch,lstrack(1,istn),1,8)
      NCH = ichmv_ch(IBUF2,nch,' rack >')
      NCH = ichmv_ch(IBUF2,nch,'< ')
      nch = ichmv(ibuf2,nch,lstrec(1,istn),1,8)
      NCH = ichmv_ch(IBUF2,nch,' recorder 1> ')
      if (nrecst(istn).eq.2) then
        NCH = ichmv_ch(IBUF2,nch,'< ')
        nch = ichmv(ibuf2,nch,lstrec2(1,istn),1,8)
        NCH = ichmv_ch(IBUF2,nch,' recorder 2 >')
      endif
      call writf_asc(LU_OUTFILE,KERR,IBUF2,(NCH+1)/2)

      CALL writf_asc_ch(LU_OUTFILE,kERR,'enddef')
C
      RETURN
      END

