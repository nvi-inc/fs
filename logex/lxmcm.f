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
      subroutine lxmcm(lscx,nscx,nstx)
C
C  LXMCM
C
C  1.0 LXMCM program specification
C
C  1.1 LXMCM determines the number of command names specified and
C      stores them into a command array. These command names are
C      passed back to the calling program LOGEX. LOGEX must match
C      these names before the log entry is listed.
C
C  MODIFICATIONS:
C
C     DATE     WHO  DESCRIPTION
C     810204   KNM  SUBROUTINE WRITTEN
C     810810   KNM  <COMMAND>=? CHANGED TO <COMMAND>
C     820329   KNM  SUBROUTINES ARGUMENTS WERE CHANGED AND LXCOM
C                   COMMON WAS INCLUDED.
C
C  1.3 REFERENCES: LOGEX: Examining the logs/Mark III Field System
C                  Documentation.
C
C  2.0 LXMCM interface
C
C  2.1 CALLING SEQUENCE: CALL LXMCM(see above...)
C
      integer*2 lscx(6,5)
C        - This array stores a maximum of five commands.
C
      dimension nscx(5)
C        - Maximum number of characters in each command name.
C
C     NSTX - Total number of commands specified.
C
C  2.2 COMMON BLOCKS USED:
C
      include 'lxcom.i'
C
C      CALLED SUBROUTINES:
C
C      LOGEX - Main Program
C
C      CALLING SUBROUTINES:
C
C      File manager package routines
C      Character manipulation routines
C      GTPRM - parses the input buffer and returns the next parameter.
C
C  3.0 LOCAL VARIABLES:
C
C     JSTX - total number of parameters possible
C
      dimension ireg(2),iparm(2),ival(2)
C        - Registers for reading; parameters from GTPRM
C        - REG, PARM - two word variables equiv
C
      equivalence (reg,ireg(1)),(parm,iparm(1)),(value,ival(1))
C
      integer*2 lc(4,2)
C        - This array contains the words COMMAND & STRING for
C          writing out what type of command was specified.
      character cjchar
C
C  INITIALIZED VARIABLES:
C
      data jstx/5/
      data lc/2hco,2hmm,2han,2hd ,2hst,2hri,2hng,2h  /
C          command string
C
C
C Determine which command was specified.
C
      if (ikey.eq.2) inxkey=1
      if (ikey.eq.10) inxkey=2
C
C
C  ************************************************************
C
C  1. Determine whether the command has an equals sign. If not,
C     write out the commands previously specified.
C
C  ************************************************************
C
C
      if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 300
      if (nstx.eq.0) goto 50
      write(luusr,9100) (lc(k,inxkey),k=1,4),((lscx(j,i),j=1,6),i=1,nstx
     .)
9100  format(1x,4a2,"="4(6a2,","),6a2)
      goto 500
50    call po_put_c(' none specified')
      goto 500
C
C
C  ************************************************************
C
C  2. Determine which commands were specified and store them in
C     the command array.
C
C  ************************************************************
C
C
300   ich=ieq+1
      nstx=0
      do i=1,jstx
        ich1=ich
        call gtprm(ibuf,ich,nchar,1,parm,id)
        if (cjchar(iparm,1).eq.',') goto 500
        nstx=nstx+1
        call ifill_ch(lscx(1,nstx),1,12,' ')
        nscx(i)=min0(ich-(ich1+1),12)
        call ichmv(lscx(1,nstx),1,ibuf,ich1,nscx(i))
        if (ichcm(ibuf,ich,lscx(1,nstx),1,nscx(i)).eq.0) nstx=nstx-1
      end do
C
500   continue
      return
      end
