      SUBROUTINE READline(IUNIT,lstring,keof,ierr,imode)
C
C  READS reads the schedule file lines.
C
      include '../skdrincl/skparm.ftni'
C
C  INPUT:
      integer iunit     !lu unit
      integer imode
      character*(*) lstring  !string to read lineinto
C     IMODE - mode for reading
C             1 = get the next record with $ in column 1
C             2 = get the next non-comment, stop when a record
C                 with $ in col. 1 is encountered.
C                 A comment card has * in column 1
C
C  OUTPUT:
      logical keof      !hit end of file
      integer ierr    !<>0, eof or some other error.
C
C  LOCAL:
C HISTORY:
!     local
      logical kprint
      character*1024 ldum
      integer ilen

      ilen=min(1024,len(lstring))


C     0. INITIALIZE
C
      ierr = 0
      lstring= " "
      keof=.false.
      kprint=.false.

100   continue
      read(iunit,'(a1024)',err=500,end=600) ldum
      lstring=ldum(1:ilen)
      if(kprint) write(*,'(a)') lstring(1:40)
      if(imode .eq. 1) then
        if(lstring(1:1) .eq. "$") return
        goto 100
      else if(imode .eq. 2) then
        if(lstring(1:1) .eq. "*" .or. lstring.eq. " ") goto 100
!        if(lstring(1:1) .eq. "$") return
      else if(imode .eq. 3) then
        return
      else
        write(*,*) "Readline: Unknown mode: ", imode
      endif

500   continue
      ierr=1
      return
600   continue
      keof=.true.
      ierr=10
      return
      END
