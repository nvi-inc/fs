      subroutine follow_link(fname,link,ierr)
      character*(*) fname,link
c
c  follow_link follows the links (if any) that start with the 
c  FS_ROOT//'/proc''//fname//'.prc' filename
c  it returns in "link" the final filename pointed too, but
c  is blank if fname//'.prc' is not a link,
c  follow_link will follow  an arbitrarily long series of links,
c  but they must all be within FS_ROOT//'/proc/'
c
c   input: fname - part of the .prc file name before the .prc and after
c                  FS_ROOT//'/proc/'
c
c   output: link - blank if fname isn't a link or error
c                  the part of the final filename after FS_ROOT//'/proc/'
c       
c           ierr = 0 for no error, <0 for error
c
      include '../include/params.i'
c
      character*65 fname1
      integer fc_readlink,trimlen
      logical kerr

      fname1 = FS_ROOT //'/proc/' // fname // '.prc'//char(0)
      link=' '
      iret=0
      icount=0
      do while(iret.ge.0)
         icount=icount+1
         iret=fc_readlink(fname1,link,ierr)
         if(iret.gt.0) then
            fname1  = FS_ROOT//'/proc/'
     &           // link(:iret)//char(0)
         else if(iret.lt.0.and.ierr.ne.22) then
            fname1=fname1(:trimlen(fname1)-1)
            if(kerr(ierr,me,'following link',fname1,0,0)) then
               link=' '
               ierr=-1
               return
            endif
         else if(iret.eq.0) then
            fname1=fname1(:trimlen(fname1)-1)
            if(kerr(-2,me,'empty link',fname1,0,0)) then
               link=' '
               ierr=-2
               return
            endif
         endif
         enddo

         if(link.ne.' ') then
            iprc=index(link,".prc")
            if(iprc.eq.0) then
               fname1=fname1(:trimlen(fname1)-1)
               if(kerr(-3,me,'no .prc in',fname1,0,0)) then
                  link=' '
                  ierr=-3
                  return
               endif
            endif
         endif
         ierr=0
         return
         end
