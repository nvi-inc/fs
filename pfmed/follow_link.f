*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
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
      character*11 me
      integer fc_readlink,trimlen
      logical kerr
      data me/'follow_link'/

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
            call fc_perror(fname1)
            link=' '
            ierr=-1
            return
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
