      subroutine VREAD(cfile,lu,iret,ivexnum,ierr)

C     VREAD calls the routines to read a VEX file.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/statn.ftni'

C History
C 960522 nrv New.

C Input
      character*(*) cfile ! VEX file path name
      integer lu

C Output
      integer iret ! error return from VEX routines
      integer ierr ! error return, non-zero
      integer ivexnum

C Local
      character*20 cbuf
      integer fvex_open,ptr_ch
      integer i

      write(lu,'("VREAD01 -- Got a VEX file to read.")')

C  1. Open the file

      ierr=1
      call null_term(cfile)
      iret = fvex_open(ptr_ch(cfile),ivexnum)
      if (iret.ne.0) return

C  2. Read the sections

      cbuf='$STATIONS'
      call null_term(cbuf)
      write(lu,'(a)') cbuf
      call vstinp(ivexnum,lu,ierr) ! stations
      if (ierr.ne.0) then
        write(lu,'("VREAD01 - Error reading stations.")')
      endif
      write(lu,'("$MODES")')
      call vmoinp(ivexnum,lu,ierr) ! modes
      if (ierr.ne.0) then
        write(lu,'("VREAD02 - Error reading modes.")')
      endif
      write(lu,'("$SOURCES")')
      call vsoinp(ivexnum,lu,ierr) ! sources
      if (ierr.ne.0) then
        write(lu,'("VREAD03 - Error reading sources.")')
      endif
C     call vobinp(ivexnum,lu,ierr) ! observations
C     if (ierr.ne.0) then
C       write(lu,'("VREAD04 - Error reading observations.")')
C     endif

C  3. Initialize parameters to standard values. These
C     are parameters not read in from the vex file.
C     Early start, late stop, and time gape were read in.

      isettm = 20
      ipartm = 70
      itaptm = 1
      isortm = 5
      ihdtm = 6

      return
      end
