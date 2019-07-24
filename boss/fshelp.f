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
      else
        cstring='help.__'
        length=7
      endif
c
      call fs_get_drive(drive)
      call fs_get_rack(rack)
      ierr = 0
      call helpstr(cstring,length,rstring,rack,drive,ierr)
      if(ierr.ne.-3) then
        runstr= 'helpsh '//rstring
        call ftn_runprog(runstr,idum)
      else
       call putcon_ch('No help for '//cstring(:length))
      endif
c
9999  continue
      return
      end
