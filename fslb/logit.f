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
      subroutine logit(lmessg,nchar,lsor,lprocn,ierr,lwho,lwhat,nargs)

C  LOGIT formats a buffer for the log file and puts it into a
C  mailbox for DDOUT.
C  Character messages are displayed as is, errors are formatted
C  in a standard format. 
C  For normal messages, only 4 parameters need be input. 
C  For the command which terminates Field System operation,
C  the error parameter (5) is used as a cue to CLOUT to clear the class
C  after the message is processed. 
C  The error parameter (5) is also used by DDOUT as a signal 
C  to start a new log file.
C  If only 2 parameters are input, the calling program's name
C  prefaces the message. 
C  For error messages, all 6 (7 if LWHAT is present) parameters are
C  required although the message and procedure name are ignored. 
C 
      include '../include/fscom.i'
C 
C  INPUT: 
C 
      dimension lmessg(1) 
C      - the buffer holding the message 
C     NCHAR - length of the message, in characters
C     LSOR - source of the message, 1 character (determined by BOSS)
      dimension lprocn(1) 
C      - the procedure file from whence this message came, 12 chars 
C     IERR - error number, if this is an error. 
C            -999 indicates termination for CLOUT and DDOUT.
C     LWHO - source of the error, 2 chars, e.g. Qx for QUIKR or BO for BOSS.
C     LWHAT - what caused the error (usually a device name), 2 chars. 
C             If LWHAT is binary, it is converted to a 4-char ASCII number. 
C             Indicate that LWHAT is binary by setting LPROCN>0.
C             This parameter should be 0 or not present if not relevant.
C 
C  OUTPUT:  none
C 
C  LOCAL: 
C 
C     NCH - character counter in IBUF 
      integer*2 ibuf(MAX_CLS_MSG_I2)
C      - buffer in which log entry is formatted 
C     NARGS - number of arguments passed to us
      character*2 copt2
C     IOPT2/COPT2 - sent as optional parameter 2 on the class I/O.
C             "B1" indicates an error, a bell is used on the terminal display
C                  for negative values, positive values are warnings
C 
C  INITIALIZED: 
C 
C 
C 
C     1. Get the number of parameters we were sent. 
C     Set up the class I/O option.
C 
      iopt2 = 0 
      copt2 =' '
      if (nargs.gt.5) then
        copt2='b1'
      endif
      if (nargs.eq.5) then
        iopt2 = ierr
        ierr = 0
      end if
C                   If there are exactly 5 arguments, then
C                   transfer the IERR parameter directly. 
C 
C 
C     2. Call LOGEN to format the message.  Call it with the appropriate
C     number of parameters, depending on NARGS. 
C 
      if (nargs.eq.2) call logen4(ibuf,nch,lmessg,nchar) 
      if (nargs.eq.3) call logen5(ibuf,nch,lmessg,nchar,lsor)
      if (nargs.eq.4) call logen6(ibuf,nch,lmessg,nchar,lsor,lprocn) 
      if (nargs.eq.-4) call logen6d(ibuf,nch,lmessg,nchar,lsor,lprocn) 
      if (nargs.eq.5) call logen7(ibuf,nch,lmessg,nchar,lsor,lprocn, 
     .                ierr) 
      if (nargs.eq.6) call logen8(ibuf,nch,lmessg,nchar,lsor,lprocn, 
     .                ierr,lwho)
      if (nargs.eq.7) call logen9(ibuf,nch,lmessg,nchar,lsor,lprocn, 
     .                ierr,lwho,lwhat)
C 
C 
C     4. The buffer is formatted.  Pad with a blank for disk writing
C     purposes and put it into the mailbox.  That's all we do.
C 
      if(mod(nch,2).eq.1) then
         nch = ichmv_ch(ibuf,nch,' ')-2
C        Pad with a blank
      else
         nch=nch-1
      endif
c
      call fs_get_iclbox(iclbox)
      if(nargs.eq.5) then
        call put_bufi(iclbox,ibuf,-nch,'fs',iopt2) 
      else
        call put_buf(iclbox,ibuf,-nch,'fs',copt2) 
      endif
C 
      return
      end 
