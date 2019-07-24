      subroutine purn(lui,lnam1,lproc,lstp,lprc,pathname,ierr)
C
C  THIS SUBROUTINE WAS WRITTEN FOR USE BY THE PFMED COMMANDS
C  PFRN AND PFPU. IT MAKES THE FOLLOWING CHECKS: ACTIVE FILES
C  FOR PFMED AND OPRIN, FILE EXISTENCE, AND "STATION" PROCEDURE
C  FILE. IT RETURNS A -1 IN IERR AFTER A TRUE ERROR REPORT.
C
C  INPUT PARAMETERS
      character*12 lnam1,lproc,lstp,lprc
      character*28 pathname
C  OUTPUT PARAMETERS
      integer ierr
C
C  LOCAL VARIABLES
      logical kex
      integer nch,trimlen
C
C  WHO  WHEN    DESCRIPTION
C  GAG  910318  CREATED
C
  
      ierr = 0
      if (lnam1.ne.lproc) then
        inquire(file=pathname,exist=kex)
        if (.not.kex) then
          nch=trimlen(pathname)
          write(lui,1101) pathname(:nch)
1101      format(" file ",a," does not exist")
          ierr = -1
          return
        end if
      else
        write(lui,9100)
9100    format(" cannot perform operation on open pfmed library")
        ierr = -1
        return
      end if
      if (lnam1.eq.lstp) then
        write(lui,9200)
9200    format(" cannot perform operation on current station library")
        ierr = -1
        return
      endif
      if (lnam1.eq.lprc) then
        write(lui,9300)
9300    format(" cannot perform operation on current field system"
     .         " proc library")
        ierr = -1
        return
      endif
  
      return
      end
