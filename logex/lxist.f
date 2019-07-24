      subroutine lxist
C 
C LXIST - Writes the Log Output to a LU or Output file. 
C 
C MODIFICATIONS:
C 
C    DATE     WHO  DESCRIPTION
C    820326   KNM  SUBROUTINE CREATED 
C 
C    820416   KNM  THE LISTING OF A LOG CAN BE WRITTEN INTO AN OUTPUT 
C                  FILE IF THE OUTPUT COMMAND SPECIFIED A FILE NAME.
C 
C    820816   KNM  THE LOG IS NO LONGER WRITTEN OUT BY THIS ROUTINE.  
C                  LXIST CALLS LXWRT WHICH WRITES OUT THE LOG.
C 
C COMMON BLOCKS USED: 
C 
      include 'lxcom.i'
C 
C SUBROUTINE INTERFACES:
C 
C    CALLING SUBROUTINES:      LOGEX - Main program 
C    CALLED SUBROUTINES:
C 
C      LNFCH Utilities
C      LXWRT - Writes out LOGEX data
C 
C 
C  ************************************************************** 
C 
C  Call LXGET to read a log entry. If there is no error or end of 
C  listing write out IBUF.
C 
C  **************************************************************
C
C
      iout=0
      ilen=0
100   call lxget
      if (icode.eq.-1.or.lstend.eq.-1.or.ilen.lt.0) goto 200
      call lxwrt(ibuf,ilen)
      nlout=nlout+1
      goto 100
C
200   continue
      return
      end
