      subroutine mvdis(ip,iclcm)
C  tape motion display   <880620.1431>

      include '../include/fscom.i'

      dimension ip(1) 
      dimension ireg(2) 
      integer get_buf
      integer*2 ibuf(20),ibuf2(50)
      equivalence (ireg(1),reg) 
      data ilen/40/,ilen2/100/
C 
C     1. This is the display section for responses to tape move commands. 
C     Get class buffer with command in it.  Set up first part 
C     of output buffer.  Get first buffer from MATCN. 
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      if (ierr.lt.0 .or. iclass.eq.0) return
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C                   Get command buffer
      nch = ichmv_ch(ibuf2,ireg(2)+1,'/') 
C                   Put / to indicate a response
C 
      if ((drive.eq.and(drive,MK3)).or.(MK4.eq.and(drive,MK4))) then
        do i=1,ncrec
          ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
          if (nch+ireg(2)-2.le.ilen2) then
            if (i.ne.1) nch=mcoma(ibuf2,nch)
            nch = ichmv(ibuf2,nch,ibuf(2),1,ireg(2)-2)
C                     Move buffer contents into output list 
          endif
        enddo
      else
        call fc_mvdis_v(ip,ibuf2,nch)
        if(ip(3).lt.0) return
      endif
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qs',ip(4),1,2)
      return
      end 
