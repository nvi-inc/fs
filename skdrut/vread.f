      subroutine VREAD(cbuf,cfile,lu,iret,ivexnum,ierr)

C     VREAD calls the routines to read a VEX file.
C  Called by sked and drudg. Reads sections for experiment,
C  sources, stations, and modes. Observations are read in
C  a VOB1INP.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/statn.ftni'

C History
C 960522 nrv New.
C 970114 nrv Stop if the supported VEX version is not found.
C 970124 nrv Add a call to VGLINP, and a call to errormsg

C Input
      character*(*) cfile ! VEX file path name
      integer lu
      character*(*) cbuf ! buffer with first line of VEX file in it

C Output
      integer iret ! error return from VEX routines
      integer ierr ! error return, non-zero
      integer ivexnum

C Local
      integer fvex_open,ptr_ch
      integer i,trimlen

      i=trimlen(cbuf)
      write(lu,'("VREAD01 -- Got a VEX file to read, ",a".")') 
     .cbuf(1:i)
      if (cbuf(i-3:i).ne.'1.5;') then
        write(lu,'("VREAD02 -- Only version 1.5 is supported, sorry.")')
        stop
      endif
      
C  1. Open the file

      ierr=1
      call null_term(cfile)
      iret = fvex_open(ptr_ch(cfile),ivexnum)
      if (iret.ne.0) return

C  2. Read the sections

      cbuf='$EXPER'
      call null_term(cbuf)
      write(lu,'(a)') cbuf
      call vglinp(ivexnum,lu,ierr,iret) ! global info
      if (ierr.ne.0) then
        write(lu,'("VREAD00 - Error reading experiment info.")')
        call errormsg(iret,ierr,'EXPER',lu)
      endif
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
