      subroutine copin(lmessg,nchar)
C
C  COPIN puts a command into the operator input stream for BOSS
C
C  MODIFICATIONS:
C  DATE    WHO  DESCRIPTION
C  811009  NRV  created
C  880808  LAR  schedule BOSS with wait depending on sign of NCHAR
C  901228  GAG  Changed IPGST call to KBOSS call to see if BOSS is running
C
C  RESTRICTIONS:  Should not be used with abandon.
C
C  REFERENCES:  FS Manual Vol 2.
C
C  CALLING PARAMETERS (Input only):
C     LMESSG - the command to be executed
C     NCHAR  - number of characters in LMESSG
C
C     SPECIFICATIONS:
      integer*2 lmessg(1)
      character*6 wait
C
C  COMMON BLOCKS USED:

      include '../include/fscom.i'

C        contains:  ICLOPR - OPRIN/BOSS command class number
C
C  SUBROUTINE INTERFACE:
C     CALLING SUBROUTINES: this is a Field System utility
C     CALLED SUBROUTINES: IPGST, IGID, EXEC
C
      logical kboss
C
C  PROGRAM STRUCTURE
C
C     1. Check that BOSS is active.  If not, just terminate.
C
cxx      if (.not.kboss()) return
C
C     3. The Field System is probably running.  Send the message into
C     the OPRIN input class.
C 
      call fs_get_iclopr(iclopr)
      call put_buf(iclopr,lmessg,-iabs(nchar),2Hfs,0)
C 
C     4. Finally, schedule BOSS with OPRIN's calling card.
C 
      if(nchar.lt.0) then
        wait='wait'
      else
        wait='nowait'
      endif
      call run_prog('boss ',wait,idum,idum,idum,idum,idum) 
      return
      end 
