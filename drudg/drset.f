*
* Copyright (c) 2020-2021 NVI, Inc.
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
      SUBROUTINE DRSET(LINSTQ)
      implicit none  !2020Jun15 JMGipson automatically inserted.
C
C   DRSET reads certain parameter values from the $PARAM section
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
! functions
      integer iStringMinMatch
C
C     INPUT VARIABLES:
      integer*2 LINSTQ(*)
C      - input string, length=word 1
C
C   LOCAL VARIABLES
      integer i2long,ichmv,ias2b !functions
      integer is,ich,ic1,ic2,nc,idummy,ikey,inum
      integer*2 LKEYWD(12)
      character*24 ckeywd
      equivalence (lkeywd,ckeywd)

      integer*2 lvalue(10)
      character*20 cvalue
      equivalence (lvalue,cvalue)
      
      integer MaxPr
      parameter (MaxPr=6)
      character*15 listPr(MaxPr)
    
      data listPr/"CORRELATOR","EARLY", "MARK6_OFF", "SOURCE","SETUP",
     & "TAPE"/  

C  History
C 970401 nrv New. Copied from sked's PRSET, leaving only those
C                 parameters drudg is interested in.
! 2004Jul16  JMGipson rewritten
! 2021-12-28 JMGipson. Rewritten AGAIN. keep only parameters drudg needs. 
!
C
C  1. Now parse the input string, getting each key word and its value.
C
 
      inum=-1
      ICH = 1
100   continue
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      IF  (IC1.EQ.0) THEN
        RETURN
      END IF
      NC = IC2-IC1+1
      ckeywd=" "
      IDUMMY = ICHMV(LKEYWD,1,LINSTQ(2),IC1,NC)
      ikey = istringminmatch(listpr,MaxPr,ckeywd)
      IF  (IKEY.EQ.0) THEN  !invalid, or something drudg does noit use. 
! Don't issue an error message because it could be a parameter that sked
! knows about but not drudg.
!        write(luscn,9110) ckeywd
!9110    format('DRSET01 - ',a24,' is not a valid parameter name.')
!        RETURN
         goto 900
      END IF  !invalid    

! get argument of keyword.
      CALL GTFLD(LINSTQ(2),ICH,i2long(LINSTQ(1)),IC1,IC2)
      if (ic1.eq.0) then
         write(luscn,'("DRSET03 - Missing parameter value.")')
         return
      endif

! Store in the character string cvalue
      cvalue=" "
      nc = ic2-ic1+1
      idummy = ichmv(lvalue,1,linstq(2),ic1,nc)

      if(ckeywd .eq. "CORRELATOR") then 
         ccorname=cvalue 
! some numerical value. 
C  Numerical values
      else
        INUM = IAS2B(LINSTQ(2),IC1,IC2-IC1+1)
        IF  (INUM.lt.0) THEN
          write(luscn,
     & '("DRSET04 - Invalid parameter ",i6, " value for ", a)') 
     &     inum, ckeywd    
        END IF
        IF (ckeywd.eq.'SETUP') THEN
          ISETTM = INUM
        else if(ckeywd  .eq. 'MARK6_OFF') then
          imark6_off=inum
        ELSE IF (ckeywd .eq.'SOURCE') THEN
          ISORTM = INUM
         ELSE IF (ckeywd.eq.'TAPE') THEN
          ITAPTM = INUM
        else if (ckeywd.eq.'EARLY') then
          do is=1,nstatn
            itearl(is) = inum
          enddo
        endif  
      endif
     
C  5.  Test to see if there is more to the line which we need to
C      decode.  If so, go back to parse some more.

900   IF ((LINSTQ(1)-ICH).GT.0) GOTO 100
C
      RETURN
      END
