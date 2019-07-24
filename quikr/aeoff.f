      subroutine aeoff(ip)
C 
C     Set and display AZ/EL offsets 
C 
      include '../include/fscom.i'
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
        ip(3) = -1
        return
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C 
C     2. Parse the command: AZELOFF=<azoffset>,<eloffset> 
C 
C     2.1 First get the AZ offset and convert to radians
C 
      ich = ieq+1
      ic1 = ich 
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).eq.'*') then
        call fs_get_azoff(azoff)
        az = azoff                 !  pick up the az offset from common
      else if (cjchar(parm,1).eq.',') then
        ip(3) = -101         !  there is no default for the az offset
        return
      else
        call gtrad(ibuf,ic1,ich-2,2,az,ierr)
        if (ierr.lt.0) then
          ip(3) = -201
          return
        endif
      endif
C 
C     2.2 Next the EL offset. 
C 
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr) 
      if (cjchar(parm,1).eq.'*') then
        call fs_get_eloff(eloff)
        el = eloff                 !  pick up the el offset from common
      else if (cjchar(parm,1).eq.',') then
        ip(3) = -102                !  there is no default for the el offset
        return
      else
        call gtrad(ibuf,ic1,ich-2,2,el,ierr)
        if (ierr.lt.0) then
          ip(3) = -202
          return
        endif
      endif
C 
C     3. Plant the variables in COMMON. 
C     ***NOTE*** WE LEAVE RA DEC AND XCY OFFSETS AS THEY ARE
C 
      azoff = az
      call fs_set_azoff(azoff)
      eloff = el
      call fs_set_eloff(eloff)
      ierr = 0
C 
C     4. Now schedule ANTCN.  Tell it to do source offsets. 
C 
      call run_prog('antcn','wait',2,idum,idum,idum,idum)
      call rmpar(ip)
      return
C 
C     5. Return the offsets for display 
C 
500   continue
      call fs_get_azoff(azoff)
      call fs_get_eloff(eloff)
      az=azoff*180./pi
      el=eloff*180./pi
      nch = ichmv(ibuf,nchar+1,2H/ ,1,1)
      nch = nch + ir2as(az,ibuf,nch,10,5)
      nch = ichmv(ibuf,nch,2H, ,1,1)
      nch = nch + ir2as(el,ibuf,nch,10,5)
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,2Hfs,0)
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qo',ip(4),1,2)

      return
      end 
