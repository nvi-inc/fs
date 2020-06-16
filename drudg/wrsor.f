*
* Copyright (c) 2020 NVI, Inc.
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
      subroutine wrsor(csname,irah,iram,ras,ldsign2,idecd,idecm,decs,lu)
! Write out VLBA source name in the format:
      implicit none  !2020Jun15 JMGipson automatically inserted.
!     sname='1053+704'  ra=10h56m53.6s dec=+70d11'46"
C Write the line in the VLBA flies with the source name
C 970509 nrv New. Extracted from VLBAT.
C 980409 nrv Get rid of data statement to clean up output.
! 2006Sep26. Rewritten to use standard fortran write.\
! 2017Oct24. Handle case where RA seconds is written as 60.0s
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/sourc.ftni'

! function
      integer trimlen

C Input
      character*8 csname
      integer irah,iram
      real ras
      integer*2 ldsign2
      integer idecd,idecm
      real decs
      integer lu
C Local
! Hold local copies of the time.
      integer irah_in,iram_in
      real ras_in
      integer idecd_in,idecm_in,idecs_in
      character*2 ctemp
      integer*2 itemp
      equivalence (ctemp,itemp)
      character*1 lsq, ldq  !used to hold single and double quotes.

      character*11 lra      !used to hold RA
      character*10 ldec     !used to hold Dec strings.

      integer idecs
      lsq="'"   !single quote
      ldq='"'   !double quote

      irah_in=irah
      iram_in=iram
      ras_in=ras
! This handles special case where seconds > 59.95, which gets written as 60.0
      if(ras_in+0.05 .gt. 60.0) then
         ras_in=0
         iram_in=iram_in+1
      endif
      if(iram_in .eq. 60) then
         iram_in=0
         irah_in=irah_in+1
      endif

      write(lra,'(i2.2,"h",i2.2,"m",f4.1,"s")') irah_in,iram_in,ras_in
!        120h56m53.6s
!        123456789x12345
      if(lra(8:8)  .eq. " ") lra(8:8)="0"
      if(lra(7:7)  .eq. " ") lra(7:7)="0"

      idecd_in=idecd
      idecm_in=idecm
      IDECS_in = DECS+0.5
      if (idecs_in.ge.60) then
        idecs_in=0
        idecm_in=idecm_in+1
      endif
      if (idecm_in.ge.60) then
        idecm=0
        idecd_in=idecd_in+1
      endif


      itemp=ldsign2
      write(ldec,'(a1,i2.2,"d",i2.2,a1,i2.2,a1)')
     >   ctemp(1:1), idecd_in,idecm_in,lsq,idecs_in,ldq
!      if(ldec(1:1)  .eq. "+") ldec(1:1)=" "

      write(lu,'("sname=",a,"  ra=",a," dec=",a)')
     >       lsq//csname(1:trimlen(csname))//lsq, lra,ldec
      return
      stop
      end
