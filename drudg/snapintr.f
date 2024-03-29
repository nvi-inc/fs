*
* Copyright (c) 2020, 2023 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      SUBROUTINE SNAPINTR(IFUNC,IYR)
      implicit none  
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
      real t_acc

      data laxistype/"HADC","XYEW","AZEL","XYNS","RICH","SEST","ALGO"/
C
C
C     WHO DATE   CHANGES
! 2021-12-13 JMGipson. Removed references to Recorder 2. 
!            Also removed stuff that would be written out in piggyback mode. 
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
! 2020Jun30 Don't output tape pases, lenghth. Instead print out terid, terna, recorder.
! 2023-02-20  Increased size of writing out cexper from


      IF (IFUNC.EQ.1) THEN
        cprfx='"'
      ELSE IF (IFUNC.EQ.2) THEN
        cprfx="!*"
      END IF

      if(cexper .eq. " ") cexper='XXX'

      write(lu_outfile,"(a,a,2x,i4,1x,a,1x,a,1x,a)") cprfx,
     >cexper, iyr,cstnna(istn),cstcod(istn),cpocod(istn)
C
C     write antenna line
      write(lu_outfile,"(a,3(a,1x),$)") cprfx,
     > cstcod(istn),cstnna(istn),laxistype(iaxis(istn))
      write(lu_outfile,"(f7.4,1x,$)") axisof(istn)
      do i=1,2
        t_acc=0.d0 
        if(slew_off(i,istn) .ne. 0 .and. slew_acc(i,istn) .ne. 0) then 
           t_acc=slew_vel(i,istn)/slew_acc(i,istn)
        endif 

        write(lu_outfile,"(1x,f5.1,1x,f5.1,2(1x,f6.1),$)")
     >    slew_vel(i,ISTN)*60.d0*rad2deg,slew_off(1,istn)+t_acc,
     >    STNLIM(1,i,ISTN)*rad2deg,STNLIM(2,i,ISTN)*rad2deg
      end do
      write(lu_outfile,"(F5.1,2(1x,a))")
     > diaman(istn), cpocod(istn),cterid(istn)
!
      write(lu_outfile,"(a,a,1x,a,3(1x,f14.5),1x,a)") cprfx,
     > cpocod(istn), cstnna(istn),
     > (stnxyz(i,istn),i=1,3), coccup(istn)

! 2020Jun30
        write(lu_outfile,'(a,a,1x,a8,1x,a)') cprfx,
     >   cterid(istn)(1:4),cterna(istn)(1:8),cstrec(istn,1)

! Below commented out
C     Write terminal line
!      if(cstrec(istn,1) .eq. "Mark5A") then
!        write(lu_outfile,'(a,a,1x,a8,1x,"Mark5A")') cprfx,
!     >   cterid(istn)(1:4),cterna(istn)(1:8)
!      else
!        write(lu_outfile,'(a,a4,1x,a8,1x,i4,1x,i8)') cprfx,
!     >   cterid(istn)(1:4),cterna(istn)(1:8),maxpas(istn),maxtap(istn)
!      endif
!      write(*,*) "TERID ", cterid(istn)
!      write(*,*) "TERNA ", cterna(istn)

C  Write drudg version
      call write_drudg_version_line(lu_outfile)

C       Write equipment line
      IF (IFUNC.EQ.1) THEN ! only for non-VLBA
!        write(lu_outfile,
!     >  '(a, "Rack=",a8, "  Recorder 1=",a8, "  Recorder 2=",a8)')
!     >     cprfx,cstrack(istn),cstrec(istn,1),cstrec(istn,2)
        write(lu_outfile, '(a, "Rack=",a, "  Recorder=",a )')
     >     cprfx,cstrack(istn),cstrec(istn,1)
      endif


      RETURN
      END

