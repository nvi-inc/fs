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
      subroutine lxprc
c
c     STATIC COMMANDS C#870115:05:33#
C 
C  LXPRC
C 
C  LXPRC program specification
C 
C  LXPRC handles all of the static commands for LOGEX.
C 
C  MODIFICATIONS: 
C 
C     DATE     WHO  DESCRIPTION 
C     810204   KNM  SUBROUTINE WRITTEN
C 
C     810803   KNM  TYPE COMMAND WAS ADDED. 
C 
C     810810   KNM  THE <COMMAND>=? WAS CHANGED TO <COMMAND>
C 
C     820329   KNM  SUBROUTINE ARGUMENTS WERE CHANGED & LXCOM WAS 
C                   INCLUDED. THE CALL TO LXOPN WAS ADDED TO THE LOG
C                   COMMAND.
C 
C     820416   KNM  THE OUTPUT COMMAND REPLACED THE LU COMMAND.  THE
C                   USER MAY SPECIFY ANY LOGICAL UNIT OR AN OUTPUT
C                   FILE IN THE FORM <NAME>:<SECU.CODE>:<CARTRIDGE> 
C 
C     820525   CAK  FIXED UP TO ALLOW SCALE VALUES TO BE EQUAL
C                   (CAUSES PLOT TO SELF-SCALE). BUG IN FORMAT
C                   9520 REMOVED TO ELIMINATE FMT ERR 3 
C 
C     820607   CAK  LXPRC HAS BEEN CHANGED FROM A SUBROUTINE TO A 
C                   SEGMENT PROGRAM OF LOGEX. CALLING ARGUMENTS WERE
C                   PLACED INTO COMMON. 
C 
C     820625   KNM  THE WIDTH AND HEIGHT PARAMETERS WERE ADDED TO THE 
C                   OUTPUT COMMAND. THE WIDTH OF THE OUTPUT IS IN UNITS 
C                   OF CHARACTERS. THE HEIGHT PARAMETER IS THE LENGTH 
C                   OF THE OUTPUT DISPLAY IN TERMS OF NUMBER OF LINES.
C 
C     820816   KNM  EIGHT IF STATEMENTS TESTING THE VALUE OF IKEY WERE
C                   ELIMINATED & REPLACED WITH A COMPUTED GO TO STATE-
C                   MENT AT THE BEGINNING OF THIS ROUTINE. CALCULATING
C                   THE SCALE VALUE IN THE SCALE COMMAND WAS DELETED
C                   AND PLACED IN LXTPL.
C 
C     820825   KNM  SUBROUTINE LXLSN NOW HANDLES LOG & SKED COMMANDS
C                   WHICH SPECIFY A 2-CHAR NAME OR A FULL NAMR. 
C 
C     820909   KNM  CFILE COMMAND WAS ADDED.
C 
C     820922   KNM  WIDTH & HEIGHT PARAMETERS WERE TAKEN OUT OF THE 
C                   OUTPUT COMMAND. THE SIZE COMMAND PERFORMS THIS
C                   FUNCTION NOW. 
C 
C     850130   MWH  ALLOW OUTPUT THRU HPIB (DRIVER TYPE o'37')
C 
C     850512   WEH  FIX DEFAULT CARTRIDGE SO IT WORKS AS ADVERTISED 
C                   IN LOG COMMAND
C
C     871130   LEF  Changed back to subroutine for use with CDS.
C 
C  REFERENCES: LOGEX: Examining the logs/Mark III Field System
C                     Documentation.
C 
C  COMMON BLOCKS USED:
C 
      include '../include/fscom.i'
      include 'lxcom.i'
C 
C      CALLING SUBROUTINES: 
C 
C      File manager package routines
C      Character manipulation routines
C      GTPRM - parses the input buffer and returns the next parameter.
C      LXOPN - Open log file
C 
C  LOCAL VARIABLES: 
C 
      character*79 outbuf
      integer nchar, ichmv
      dimension iparm(1)
C 
      equivalence (parm,iparm(1))
C 
C     ICH - character counter
C     IPRM - The special character is stored in IPRM upon its return
C            from GTPRM.
C     ITLU - Variable that determines whether the output LU is a non-
C            disc devices such as a line printer or terminal.
C
      go to (100,200,300,1700,500,1700,700,800,1700,1000,1100,1700,1700,
     .1400,1500,1600),ikey
C 
C 
C     ******************* 
C     1. OUTPUT commmand. 
C     ******************* 
C 
C
100   call lxout
      goto 1700
C
C
C     ******************
C     2. COMMAND command
C     ******************
C
C
200   call lxmcm(lcomnd,ncomnd,ncmd)
      goto 1700
C
C
C     **************
C     3. LOG command
C     **************
C
C
300   if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 340
        outbuf='log= '// lognc
        call po_put_c(outbuf)
      goto 1700
C
C Get Log Name
C
340   call ifill_ch(logna,1,20,' ')
      ich=ieq+1
      ic1=ich
      icl = min(nchar-ic1+1,20)
      id = ichmv(logna,1,ibuf,ic1,icl)
      call lxopn
      goto 1700
C
C
C     ******************
C     4. Help command ??
C     ******************
C
C
500   continue
      call lxhlp
      goto 1700
C
C
C     ********************
C     5. The PARM command.
C     ********************
C
C
700   call lxprm
      goto 1700
C
C
C     *********************
C     6. The SCALE command.
C     *********************
C
C
800   call lxscl
      goto 1700
C
C
C  *****************
C  7. STRING command
C  *****************
C
C
1000  call lxmcm(lstrng,nstrng,nstr)
      goto 1700
C
C
C  ********************
C  8. The TYPE command.
C  ********************
C
C
1100  call lxtyp
      goto 1700
C
C
C ********************
C
C 9. The SKED command.
C
C ********************
C
C
1400  call lxskd
      goto 1700
C
C
C ******************
C
C 10. CFILE command.
C
C ******************
C
C
1500  call lxcfl
      goto 1700
C
C
C ********************
C
C 11. The SIZE Command
C
C ********************
C
C
1600  call lxsze
      goto 1700
C
1700  continue
      return
      end
