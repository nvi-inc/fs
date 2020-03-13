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
      subroutine redsk(ibufsk,iskbw)
C
C  REDSK - This routine reads the schedule file until the $SKED section
C          is encountered.
C
C  COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C  MODIFICATIONS:
C
C     DATE     WHO  DESCRIPTION
C     820513   KNM  SUBROUTINE CREATED
C
C  INPUT VARIABLES:
C
      integer*2 ibufsk(80)
C        - Buffer for schedule file.
      integer fmpread
C
C     ISKBW - Number of words in IBUFSK
C
C  OUTPUT VARIABLES:
C
C     ICODE - Error flag.
C
C  SUBROUTINE INTERFACES:
C
C     CALLED SUBROUTINES:
C
C       LXSUM - SUMMARY command.
C
C  **********************************************************
C
C  Read the schedule file until the $SKED section is reached.
C  If the $SKED section is not found before the end of file,
C  write a message.
C
C  **********************************************************
C
C
100   call ifill_ch(ibufsk,1,160,' ')
      id = fmpread(idcbsk,ierr,ibufsk,iskbw*2)
      ilensk = iflch(ibufsk,iskbw*2)
C
      if (ierr.lt.0) then
        write(luusr,9000) ierr,lskna
9000    format("REDSK10 - error "i3" reading sked file "4a2)
        icode=-1
        goto 300
      end if
C
      if (ichcm_ch(ibufsk,1,'$sked').eq.0) goto 300
      if (ilensk.ge.0) goto 100
        call po_put_c('eof was encountered before $sked section')
        icode=-1
C
300   continue
      return
      end
