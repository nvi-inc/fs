      subroutine reprc(fname)
C
      include '../include/params.i'
  
C IN PARAMETERS
      character*(*) fname
C
C LOCAL VARIABLES
      character*64 fname1,fname2,link
      integer trimlen,nch,ierr,ierr1,ierr2
      logical kerr
      character*5 me
      data me/'reprc'/
  
      nch = trimlen(fname)
      if (nch.gt.0) then
         ierr=0
         call follow_link(fname(:nch),link,ierr)
         if(ierr.ne.0) return

         if(link.eq.' ') then
            fname1 = FS_ROOT //'/proc/' // fname(:nch) // '.prc'
         else
            fname1 = FS_ROOT //'/proc/'//link(:trimlen(link))
         endif
               
         call ftn_purge(fname1,ierr)
         if(kerr(ierr,me,'purging',fname1,0,0)) return
         
         if(link.ne.' ') then
            link(iprc+3:iprc+3)='x'
            fname2= FS_ROOT//'/proc/' // link(:trimlen(link))
         else
            fname2 = FS_ROOT//'/proc/' // fname(1:nch) // '.prx'
         endif
         call ftn_rename(fname2,ierr1,fname1,ierr2)

         if(kerr(ierr1,me,'renaming',fname2,0,0)) continue
         if(kerr(ierr2,me,'renaming',fname1,0,0)) return
      end if
  
      return
      end
