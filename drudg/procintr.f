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
      include 'hardware.ftni'
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
! 2005Aug08 JMGipson.  Simplified.

C Input
!    None.

! functions
      integer trimlen
C  LOCAL:
      integer*2 IBUF2(80)
      character*160 cbuf2
      equivalence (cbuf2,ibuf2)
      integer iblen
      integer idummy,nch,kerr
      integer ichcm_ch,ichmv,ichmv_ch,ib2as
      character*1 lq

      lq='"'
C
      cbuf2="define proc_library 00000000000x"
      write(lu_outfile,'(a)') cbuf2(1:34)

      IF (ichcm_ch(LEXPER,1,'        ').EQ.0)  THEN
        IDUMMY = ichmv_ch(LEXPER,1,'XXX     ')
      END IF
      cbuf2=lq
      nch=3
      NCH = ICHMV(IBUF2,NCH,LEXPER,1,8)
      NCH = ICHMV(IBUF2,NCH+3,LSTNNA(1,ISTN),1,8)
      NCH = ICHMV(IBUF2,NCH+2,LPOCOD(ISTN),1,2)

      nch=trimlen(cbuf2)
      write(lu_outfile,'(a)') cbuf2(1:nch)

      CALL IFILL(IBUF2,1,iblen,32)
      cbuf2='" drudg version '//cversion(1:6)
      nch=24
!      nch=ichmv_ch(ibuf2,1,'" drudg version ')
!      nch=ichmv_ch(ibuf2,nch,cversion(1:6))
      nch=ichmv_ch(ibuf2,nch,' compiled under FS ')
      idummy=iVerMajor_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      nch = ichmv_ch(ibuf2,nch,'.')
      idummy=iVerMinor_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      nch = ichmv_ch(ibuf2,nch,'.')
      idummy=iVerPatch_FS
      nch = nch + ib2as(idummy,ibuf2,nch,o'100000'+5)
      write(lu_outfile,'(a)') cbuf2(1:nch)


      write(lu_outfile,'(5a,$)')
     >   '"< ',cstrack(istn),' rack >< ',cstrec(istn), ' recorder 1>'
      if(nrecst(istn) .eq. 2) then
        write(lu_outfile,'("< ",a," recorder 2>")') cstrec2(istn)
      else
        write(lu_outfile, '(a)')
      endif

      if(km5A_piggy) then
        write(lu_outfile,90) "   Mark5A operating in piggyback mode."
      endif
      if(km5P_piggy) then
        write(lu_outfile,90) "   Mark5P operating in piggyback mode."
      endif

      write(lu_outfile,'(a)') 'enddef'

90    format('"',a,'"')
C
      RETURN
      END

