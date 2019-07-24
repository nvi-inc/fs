      subroutine fshelp(ibuf,istart,nchar)
C
      include '../include/fscom.i'
C  INPUT VARIABLES:
      integer*2 ibuf(1)    ! command buffer
C     ISTART: INDEX OF START OF NAME OF COMMAND FOR WHICH HELP IS DESIRED
C     NCHAR:  END OF COMMAND STRING
C  OUTPUT VARIABLES: none
C  LOCAL VARIABLES:
C     RUNSTR:  runstring for calling programs
C  PROGRAMMER:  Lloyd Rawley     early February 1988
C
      character*100 runstr,cstring,rstring

      if (istart.ne.0) then
        length = nchar+1-istart
        call hol2char(ibuf,istart,nchar,cstring)
        call fs_get_drive(drive)
        call fs_get_rack(rack)
        ierr = 0
        call helpstr(cstring,length,rstring,rack,drive,ierr)
        runstr= 'helpsh '//FS_ROOT//'/fs/help/'//rstring
      else
        runstr='helpsh '//FS_ROOT//'/fs/help/help.__'
      endif
      call ftn_runprog(runstr,idum)

9999  continue
      return
      end
