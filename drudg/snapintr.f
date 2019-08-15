      SUBROUTINE SNAPINTR(IFUNC,IYR)
C
C This routine writes out the header information for snap files and
C vlba pointing files in the LU_OUTFILE.
C
      include 'hardware.ftni'
      include '../skdrincl/constants.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      integer ifunc,IYR ! ifunc=1 for " comments, ifunc=2 for !* comments
C
C  LOCAL:
      character*2 cprfx
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
! 2006Jul19 JMGipson.  Increased format length for tape so don't have overflow.
! this is the start of the line
! 2006Nov30 Use cstrec(istn,irec) instead of 2 different arrays
! 2007Dec07 Modified so that  prints version as ....
! 2018Jul20 Moved writing of drudg version to subrotine. 

      IF (IFUNC.EQ.1) THEN
        cprfx='"'
      ELSE IF (IFUNC.EQ.2) THEN
        cprfx="!*"
      END IF

      if(cexper .eq. " ") cexper='XXX'

      write(lu_outfile,"(a,a8,2x,i4,1x,a,1x,a,1x,a)") cprfx,
     >cexper(1:8), iyr,cstnna(istn),cstcod(istn),cpocod(istn)
C
C     write antenna line
      write(lu_outfile,"(a,3(a,1x),$)") cprfx,
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
      write(lu_outfile,"(a,a,1x,a,3(1x,f14.5),1x,a)") cprfx,
     > cpocod(istn), cstnna(istn),
     > (stnxyz(i,istn),i=1,3), coccup(istn)

C     Write terminal line
      if(cstrec(istn,1) .eq. "Mark5A") then
        write(lu_outfile,'(a,a4,1x,a8,1x,"Mark5A")') cprfx,
     >   cterid(istn)(1:4),cterna(istn)(1:8)
      else
        write(lu_outfile,'(a,a4,1x,a8,1x,i4,1x,i8)') cprfx,
     >   cterid(istn)(1:4),cterna(istn)(1:8),maxpas(istn),maxtap(istn)
      endif

C  Write drudg version
      call write_drudg_version_line(lu_outfile)

C       Write equipment line
      IF (IFUNC.EQ.1) THEN ! only for non-VLBA
        write(lu_outfile,
     >  '(a, "Rack=",a8, "  Recorder 1=",a8, "  Recorder 2=",a8)')
     >     cprfx,cstrack(istn),cstrec(istn,1),cstrec(istn,2)
      endif
      if(KM5A_Piggy)  write(lu_outfile,'(a,a)')
     >      cprfx,"Mark5A operating in piggyback mode "

      if(KM5P_Piggy)  write(lu_outfile,'(a)')
     >      cprfx,"Mark5P operating in piggyback mode "


      RETURN
      END

