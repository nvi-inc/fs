      SUBROUTINE PROCINTR
C
C This routine writes out the header information for proc files.
C into lu_outfile.
C
      include 'hardware.ftni'
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
! 2005Aug08 JMGipson.  Simplified.
! 2006Nov30 Use cstrec(istn,irec) instead of 2 different arrays

C Input
!    None.

! functions
C  LOCAL:
      character*2 cprfx

      cprfx='" '
C
      write(lu_outfile,'(a)') "define  proc_library  00000000000x"

      if(cexper .eq.  " ") cexper="XXX"

      write(lu_outfile,'(a,a,3x,a,2x,a)')
     > cprfx,cexper,cstnna(istn),cpocod(istn)

      write(lu_outfile,
     >   "(a,'drudg version ',a9,' compiled under FS ',i2,2('.',i2.2))")
     >    cprfx,cversion,iVerMajor_FS,iverMinor_FS,iverPatch_FS

      write(lu_outfile,'(5a,$)')
     >   '"< ',cstrack(istn),' rack >< ',cstrec(istn,1), ' recorder 1>'
      if(nrecst(istn) .eq. 2) then
        write(lu_outfile,'("< ",a," recorder 2>")') cstrec(istn,2)
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

