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
      SUBROUTINE PREFR(RAIN,DECIN,IEPIN,RAOUT,DECOUT)
C
C     Rotation of reference frames to/from B1950 and J2000
C     Fortran code from D. Graham, transcribed by NRV
C
C     RAIN,DECIN - ra, dec of original epoch IEPIN, radians
C     RAOUT,DECOUT - ra,dec of new epoch, radians
C     IEPIN - original epoch, either 1950 or 2000 only
C           - new epoch is assumed to be 2000 or 1950, respectively
C
      implicit none
      include "../skdrincl/constants.ftni"
      real*8 PSI,PHI,THI,RAIN,DECIN,RAOUT,DECOUT
      integer iepin
      real*8 X,Y,Z,X1,Y1,Z1
      real*8 CS,CP,CT,SS,SP,ST
C
C  HISTORY
C  890103 NRV Created, tested
C
      PSI = -19.243561D0*PI/(180.D0*60.D0)
      PHI = -19.197312D0*PI/(180.D0*60.D0)
      THI = 16.704244D0*PI/(180.D0*60.D0)
C
      IF (IEPIN.EQ.2000) THEN !rotate 2000 -> 1950
        PSI = -PSI
        PHI = -PHI
        THI = -THI
      ENDIF
C
      X = DSIN(RAIN)*DCOS(DECIN)
      Y = DCOS(RAIN)*DCOS(DECIN)
      Z = DSIN(DECIN)
C
      CS = DCOS(PSI)
      CP = DCOS(PHI)
      CT = DCOS(THI)
      SS = DSIN(PSI)
      SP = DSIN(PHI)
      ST = DSIN(THI)
C
      X1 = X*(CS*CP-CT*SP*SS)-Y*(SS*CP+CT*SP*CS)+Z*ST*SP
      Y1 = X*(CS*SP+CT*CP*SS)-Y*(SS*SP-CT*CP*CS)-Z*ST*CP
      Z1 = X*ST*SS+Y*ST*CS+Z*CT
C
      DECOUT = DASIN(Z1)
      RAOUT = DATAN2(X1/DCOS(DECOUT),Y1/DCOS(DECOUT))
      IF (RAOUT.LT.0.D0) RAOUT=RAOUT+2.D0*PI
C
      RETURN
      END
