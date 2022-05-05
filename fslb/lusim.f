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
      function lusim(lu,kdef)

C  THIS ROUTINE SIMULATES THE LU OF THE USER UNLESS IT HAS 
C  BEEN CALLED WITH THE VALUE TO USE, WHICH TAKES PRECEDENCE.  THE 
C  VALUES RETURNED ARE AS FOLLOWS. 
C 
C  LUSIM=1         RTE-M AND NOT INITIALIZED 
C 
C       =LU        FROM LAST CALL WITH SECOND PARAMETER
C
C       =IDSEG-LU  IF NEVER DEFINED AND IN RTE-4 
C 
C  CALLING SEQUENCE: CALL LUSIM(LU,KDEF)
C 
C  INPUT VARIABLES:
C 
C       LU      - USED TO DEFINE LUDEF IF SECOND PARAMETER, ELSE UNUSED 
C 
C       KDEF    - IF PRESENT INDICATES LUDEF TO BE DEFINED
C 
C  OUTPUT VARIABLES: 
C 
C       LUSIM   - THE VALUE FOR THE LU AS DESCRIBED ABOVE 
C 
C  CALLING SUBROUTINES: SUB1, SUB2, ... (not required for utilities) 
C  CALLED SUBROUTINES: SUB1, SUB2, ... (includes segments scheduled) 
C 
C 3.  LOCAL VARIABLES 
C 
C       LUDEF   - FLAG INDICATING VALUE OF LU DEFINED BE USER IF PRESENT
C 
C       IRGA    - CONTENTS OF A REG WHERE REG WAS RETURNED FROM FUNCTION
C                 CALL TO A ROUTINE 
C 
C       IRGB    - CONTENTS OF B-REG WHERE REG WAS RETURNED FROM FUNCTION
C                 CALL TO A ROUTINE 
C 
      dimension ireg(2) 
C 
C       IREG    - DUMMY REGISTER RETREIVAL AID
C 
      equivalence (reg,ireg(1),irga),(ireg(2),irgb) 
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ludef/1/ 
C 
C       LUDEF NOT DEFINED BY USER - ELSE WILL BE USER DEFINITION
C 
C 6.  PROGRAMMER: LEE N. FOSTER 
C     LAST MODIFIED:
C# LAST COMPC'ED  870407:11:59urrent date) #
C 
C     PROGRAM STRUCTURE
C
C       NPS=IGNPS(NPS)
c      nps=pcount()
C
C  IF DEFINITION CALL SKIP ON
C
C -ORO- nps not set above- execute line or no?
      if (nps.gt.1.and.lu.ne.0) goto 10000
C
C  IF LUDEF NOT DEFINED SKIP ON FOR SYSTEM TEST
C
      if (ludef.ne.1) goto 99999
C
C  TEST FOR RTE-IV
C
      if (nopsy(ludef).ne.-9) goto 99999
C
C  GET THE CURRENT LU FROM IDSEG - THIS IS RTE-IV
C
      ludef=-iget(iget(o'1717')+32)
C 
C  NOW EXIT
C 
      goto 99999 
C 
10000 continue
C 
C  USER DEFINITION OF LU
C 
      ludef=lu
C 
C   THAT ALL NOW EXIT 
C 
      goto 99999 
C 
99999 continue
C 
C   RETURN USER OR LAST DEFINITION OF LU 
C 
      lusim=ludef 
C 
      return
      end 
