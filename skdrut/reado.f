      subroutine reado(ivexnum,istn,lu,iret,ierr)

C     READO calls the routines to read a observations
C     from a VEX file.

C History
C 960531 nrv New.

C Input
      character*(*) cfile ! VEX file path name

C Output
      integer iret ! error return from VEX routines
      integer ierr ! error return, non-zero

C Local
      integer fvex_open,ptr_ch

C  1. Read the observations for one station.

      call vob1inp(ivexnum,istn,lu,ierr) ! observations
      if (ierr.ne.0) then
        write(lu,'("READV04 - Error reading observations.")')
      endif

      return
      end
