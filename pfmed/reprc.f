      subroutine reprc(fname)
  
C IN PARAMETERS
      character*(*) fname
C
C LOCAL VARIABLES
      character*63 fname1,fname2
      integer trimlen,nch,ierr,ierr1,ierr2
      logical kerr
      character*5 me
      data me/'reprc'/
  
      nch = trimlen(fname)
      if (nch.gt.0) fname1 = '/usr2/proc/' // fname(1:nch) // '.prc'
      call ftn_purge(fname1,ierr)
      if(kerr(ierr,me,'purging',fname1,0,0)) return
      if (nch.gt.0) fname2 = '/usr2/proc/' // fname(1:nch) // '.prx'
      call ftn_rename(fname2,ierr1,fname1,ierr2)
      if (id.ne.0) then
        if(kerr(ierr1,me,'renaming',fname2,0,0)) continue
        if(kerr(ierr2,me,'renaming',fname1,0,0)) return
      end if
  
      return
      end
