      SUBROUTINE SNAPINTR(IFUNC,IYR)
C
C This routine writes out the header information for snap files and
C vlba pointing files in the LU_OUTFILE.
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/constants.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
      include 'hardware.ftni'
C
C  INPUT:
      integer ifunc,IYR ! ifunc=1 for " comments, ifunc=2 for !* comments
C
C  LOCAL:
      character*1 lq
      character*2 cprefix
C     IYR - start time of obs.
      character*4 laxistype(7)
      integer i

      data laxistype/"HADC","XYEW","AZEL","XYNS","RICH","SEST","ALGO"/
C
C
C     WHO DATE   CHANGES
C     gag 901016 Created, copied out of snap file.
C     gag 901025 Added ! in front of the *.
C     nrv 930212 implicit none
C     nrv 940114 Write a line with EARLY.
C                Remove EARLY (LSTSUM can figure it out)
C 960227 nrv Change iterid to lterid
C 970214 nrv Write 2-letter code on first line
C 970311 nrv Write both codes on first line.
C 990325 nrv Add a drudg ID comment.
C 990401 nrv Add a FS ID comment.
C 990404 nrv Don't add FS ID for VLBA output files.
C 990628 nrv Add K4 or S2 equipment type as a comment.
C 990730 nrv Add any equipment type as a comment.
C 990803 nrv Merge drudg and FS lines and reformat.
C 991102 nrv Add recorder B.
C
C
      lq='"'
! this is the start of the line
      IF (IFUNC.EQ.1) THEN
        cprefix=lq
      ELSE IF (IFUNC.EQ.2) THEN
        cprefix="!*"
      END IF

      if(cexper .eq. " ") cexper='XXX'

      write(lu_outfile,"(a,a8,2x,i4,1x,a,1x,a,1x,a)") cprefix,
     >cexper(1:8), iyr,cstnna(istn),cstcod(istn),cpocod(istn)
C
C     write antenna line
      write(lu_outfile,"(a,3(a,1x),$)") cprefix,
     > cstcod(istn),cstnna(istn),laxistype(iaxis(istn))
      write(lu_outfile,"(f7.4,1x,$)") axisof(istn)
      do i=1,2
        write(lu_outfile,"(1x,f5.1,1x,i4,2(1x,f6.1),$)")
     >    STNRAT(i,ISTN)*60.d0*rad2deg,istcon(1,istn),
     >    STNLIM(1,i,ISTN)*rad2deg,STNLIM(2,i,ISTN)*rad2deg
      end do
      write(lu_outfile,"(F5.1,2(1x,a))")
     > diaman(istn), cpocod(istn),cterid(istn)
!
      write(lu_outfile,"(a,a,1x,a,3(1x,f14.5),1x,a)") cprefix,
     > cpocod(istn), cstnna(istn),
     > (stnxyz(i,istn),i=1,3), coccup(istn)

C     Write terminal line
      write(lu_outfile,'(a,a4,1x,a8,1x,i4,1x,i5)') cprefix,
     > cterid(istn)(1:4),cterna(istn)(1:8),maxpas(istn),maxtap(istn)

C  Write drudg version
      write(lu_outfile,
     >"(a,'drudg version ',a6,' compiled under FS ',2(i1,'.'),i2.2)")
     >cprefix,cversion,iVerMajor_FS,iverMinor_FS,iverPatch_FS

C       Write equipment line
      IF (IFUNC.EQ.1) THEN ! only for non-VLBA
        write(lu_outfile,
     >  '(a, "Rack=",a8, "  Recorder 1=",a8, "  Recorder 2=",a8)')
     >     cprefix,cstrack(istn),cstrec(istn),cstrec2(istn)
      endif
      if(KM5A_Piggy)  write(lu_outfile,'(a,a)')
     >      cprefix,"Mark5A operating in piggyback mode "

      if(KM5P_Piggy)  write(lu_outfile,'(a)')
     >      cprefix,"Mark5P operating in piggyback mode "


      RETURN
      END

