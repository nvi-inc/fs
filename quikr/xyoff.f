      subroutine xyoff(ip)
C 
C     Set and display  X/Y  offsets 
C 
      include '../include/fscom.i'
      include '../include/dpi.i'
C 
      dimension ip(1) 
      dimension ireg(2),iparm(2)
      integer get_buf
      integer*2 ibuf(20)
      character cjchar
C 
      equivalence (ireg(1),reg),(iparm(1),parm) 
C 
      data ilen/40/ 
C 
      iclcm = ip(1) 
      do i=1,3
        ip(i)=0
      enddo
      call char2hol('qo',ip(4),1,2)
      if (iclcm.eq.0) then
        ip(3)=-1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C 
C     2. Parse the command:   XYOFF=< xoffset>,< yoffset> 
C 
C     2.1 First get the X offset and convert to radians 
C 
      ich = ieq+1
      ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_xoff(xoff)
        x = xoff                  !  pick up the x offset from common
      else if (cjchar(parm,1).eq.',') then
        ip(3) = -101              !  there is no default for the x offset
        return
      else
        call gtrad(ibuf,ic1,ich-2,2,x,ierr)
        if (ierr.lt.0) then
          ip(3) = -201
          return
        endif
      endif
C 
C     2.2 Next the Y offset.  
C 
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_yoff(yoff)
        y = yoff                 !  pick up the y offset from common
      else if (cjchar(parm,1).eq.',') then
        ip(3) = -102             !  there is no default for the y offset
        return
      else
        call gtrad(ibuf,ic1,ich-2,2,y,ierr)
        if (ierr.lt.0) then
          ip(3) = -202
          return
        endif
      endif
C 
C     3. Plant the variables in COMMON. 
C     ***NOTE*** WE LEAVE AZ EL AND RA DEC OFFSETS AS THEY ARE
C 
      xoff = x
      call fs_set_xoff(xoff)
      yoff = y
      call fs_set_yoff(yoff)
      ierr = 0
C 
C     4. Now schedule ANTCN.  Tell it to do source offsets.
C 
      call fs_get_idevant(idevant)
      if (ichcm_ch(idevant,1,'/dev/null ').ne.0) then
        call run_prog('antcn','wait',2,idum,idum,idum,idum)
        call rmpar(ip)
      else
        ip(3) = -302
      endif
      return
C 
C     5. Return the offsets for display 
C 
500   nch = ichmv(ibuf,nchar+1,2h/ ,1,1)
      call fs_get_xoff(xoff)
      xo=xoff*180./RPI 
      call fs_get_yoff(yoff)
      yo=yoff*180./RPI 
      nch = nch + ir2as(xo,ibuf,nch,10,5)  
      nch = ichmv(ibuf,nch,2h, ,1,1)
      nch = nch + ir2as(yo,ibuf,nch,10,5)  
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,2hfs,0)
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qo',ip(4),1,2)
      return
      end 
