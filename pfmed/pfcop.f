      subroutine pfcop(lp,lui,iret)
C
C 1.  PFCOP PROGRAM SPECIFICATION
C
C 1.1.   PFCOP copies a procedure file into scratch file 3.  If any error
C        occurs, the active procedure file is set empty.
C
C 1.2.   RESTRICTIONS - Only procedure files are accessible.  These have
C        the prefix "[PRC" which is transparent to the user.  Procedures are
C        available only on disc ICRPRC.
C
C 1.3.   REFERENCES - Field system manual
C
C 2.  PFCOP INTERFACE
C
C 2.1.   CALLING SEQUENCE: CALL PFCOP(LP,LUI,IRET)
C
C     INPUT VARIABLES:
C
      character*(*) lp
C                - target procedure file
C        LUI     - terminal LU
C
C 2.2.   COMMON BLOCKS USED:
C
      include 'pfmed.i'
C
C 2.3.   DATA BASE ACCESSES: none
C
C 2.4.   EXTERNAL INPUT/OUTPUT
C
C     INPUT VARIABLES: none
C
C     OUTPUT VARIABLES:
      integer iret   !
C
C     TERMINAL   - error message
C
C 2.5.   SUBROUTINE INTERFACE:
C
C     CALLING SUBROUTINES: PFMED, FFM, FFMP, FED
C
C     CALLED SUBROUTINES: FMP routines, IB2AS, EXEC, PFBLK
C
C 3.  LOCAL VARIABLES:
C
      character*12 lfr
C                - correct file name for reading
      character*34 pathname
      integer trimlen
      logical kex,kerr
C
C 4.  CONSTANTS USED
C
      dimension lm6(12)
C
      data lm6    /2hno,2h p,2hro,2hce,2hdu,2hre,2h f,2hil,2he ,2hac,
     /             2hti,2hve/
C          - NO PROCEDURE FILE ACTIVE
C
C 5.  INITIALIZED VARIABLES: none
C
C 6.  PROGRAMMER: C. Ma
C     LAST MODIFIED: <910322.0337>
C# LAST COMPC'ED  870115:05:40
C
C     PROGRAM STRUCTURE
C
C     Check if procedure file exists to be copied.
      if(lp.eq.'none') then
C     No procedure file - message and return.
c        call exec(2,lui,lm6,-24)
      else
        iret = 0
        call pfblk(1,lp,lfr)
        nch = trimlen(lp)
        if (nch.gt.0) pathname = '/usr2/proc/' 
     .                  // lp(1:nch) // lfr(1:4)
C     Open procedure file.
        inquire(file=pathname,exist=kex)
        if (.not.kex) then
          nch = trimlen(pathname)
          if (nch.gt.0) write(lui,9200) pathname(1:nch)
9200      format(" file ",a," does not exist!!")
          iret = -1
        else
          call fclose(idcb3,ierr)
          if(kerr(ierr,'pfcop','closing',' ',0,0)) return
          call fopen(idcb3,pathname,ierr)
          if(kerr(ierr,'pfcop','opening',' ',0,1)) return
C The last parameter tells KERR to ignore all positive IERR's
        end if
      end if

      return
      end
