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
      subroutine lxcrt
C 
C  LXCRT - Create an output if we are in non-interactive mode or if 
C          an OUTPUT command specifies a file name. 
C 
C  MODIFICATIONS: 
C 
C     DATE     WHO  DESCRIPTION 
C     820413   KNM  SUBROUTINE CREATED
C 
C  COMMON BLOCKS USED:
      include 'lxcom.i'
C
C  SUBROUTINE INTERFACES:
C     CALLED SUBROUTINES:
C       LXPRC - Process static commands.
C
C  LOCAL VARIABLES:
C
      character*79 outbuf
      integer answer, trimlen, nchar
      character cchar
      logical kfile
C
C  **************************************************************
C
C  1. Create the output file.  If the file already exists, prompt
C     the user for a decision to overwrite or to extend the file.
C
C  **************************************************************
C
C
      iout=0
      call char2hol('e ',ltell,1,2)
      il=iflch(namf,20)
      namfc(il+1:il+1) = ' '
      inquire(FILE=namfc(1:il), EXIST=kfile)
      if(.NOT.kfile)
     .  call fmpopen(jdcb,namfc(1:il),ierr,'w+',1)
      if (kfile) ierr=-2
      if (ierr.ge.0) goto 200
      if (ierr.eq.-2.and.nintv.eq.0) goto 100
      if(ierr.eq.-2.and.nintv.eq.1) goto 200
        outbuf='LXCRT10 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' creating output file'
        call po_put_c(outbuf)
        icode=-1
        goto 500
C
C  The output file already exists.  Determine whether the user wants to
C  overwrite or extend the file.
C
100   cchar=' '
      write(luusr,9100)
9100  format(/," file already exists, do you wish to (o)verwrite or (e)x
     .tend ? ",$)
      read(5,4301) cchar
4301  format(a)
      if (cchar.ne.'o' .and.cchar.ne.'e' ) goto 100
C
C
C  ************************************************************
C
C  2. Open the output file.
C
C  ************************************************************
C
C
200   ierr=0
      if (kfile)
     .  call fmpopen(jdcb,namfc(1:il),ierr,'r+',1)
      if (ierr.lt.0) then 
        outbuf='LXCRT20 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' opening output file ' // namfc
        call po_put_c(outbuf)
        icode=-1
        goto 500
      end if
C
C
C  *************************************************************
C
C  3. If the user wanted to overwrite the output file, we shall
C     return to the called routine.  Otherwise read down the
C     output file until an end of file is reached.  Reposition
C     the file for writing after the last line.
C
C  *************************************************************
C
C
      if (cchar.ne.'o' ) then
        call fmpappend(jdcb,ierr)
        goto 500
      end if
      call fmpclose(jdcb,ierr)
      call fmpopen(jdcb,namfc(1:il),ierr,'w+',1)   
      if (ierr.lt.0) then 
        outbuf='LXCRT30 - error '
        call ib2as(ierr,answer,1,4)
        call hol2char(answer,1,4,outbuf(17:))
        nchar = trimlen(outbuf) + 1
        outbuf(nchar:)=' opening output file ' // namfc
        call po_put_c(outbuf)
        icode=-1
      end if
C
500   continue
      return
      end
