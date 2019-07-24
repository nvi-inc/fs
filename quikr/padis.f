      subroutine padis(ip,iclcm)
C  patching display c#870115:04:52# 
C 
C 1.1.   PADIS gets data from common variables and displays them
C 
C 2.  PADIS INTERFACE 
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN 
C        IP(2)  - number of records in class
C        IP(3)  - error return from MATCN 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - CLASS
C        IP(2) - # RECS 
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
C 
      include '../include/fscom.i'
C 2.5.   SUBROUTINE INTERFACE:
C 
C     CALLING SUBROUTINES: PATCH
C 
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
C 
      integer*2 ibuf2(30)
C               - input class buffer, output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
C 
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 4.  CONSTANTS USED
C 
C 5.  INITIALIZED VARIABLES 
C 
      data ilen/60/ 
C 
C 6.  PROGRAMMER: NRV & MAH 
C     CREATED: 19820318 
C# LAST COMPC'ED  870115:04:52 #
C 
C     PROGRAM STRUCTURE 
C 
C     1. First check error return from MATCN.  If not 0, get out
C     immediately.
C 
C 
      if (iclcm.eq.0) return
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
C 
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      if (nch.eq.0) nch = nchar+1 
C                  If no "=" found position after last character
      nch = ichmv(ibuf2,nch,2h/ ,1,1) 
C                  Put / to indicate a response 
C 
C     2.  Now get common variables and decode for display 
C 
      ierr = 0
      iclass = 0
C 
      nch = ichmv(ibuf2,nch,2hlo,1,2) 
      do  j = 1,3
          nch = nch+ib2as(j,ibuf2,nch,o'100000'+1)
          ic1 = nch 
          jc = 0
C 
          do  i = 1,14 
            if (iabs(ifp2vc(i)).eq.j) then
              nch = mcoma(ibuf2,nch)
              nch = nch+ib2as(i,ibuf2,nch,o'100000'+2)
              call char2hol('h ',l,1,2)
              if (ifp2vc(i).lt.0) call char2hol('l ',l,1,2)
              nch = ichmv(ibuf2,nch,l,1,1)
              jc = jc+1 
            endif
          enddo
C 
          if (jc.eq.0) nch = ic1
C 
C     5. Now send the buffer to SAM and schedule PPT. 
C 
          nch = nch - 1 
          call put_buf(iclass,ibuf2,-nch,2hfs,0)
          nch = ic1-1 
      enddo
C                   Send buffer starting with IFD to display, ignoring
      if (.not.kcheck) ierr = 0 
      ip(1) = iclass
      ip(2) = 3 
      ip(3) = ierr
      call char2hol('qq',ip(4),1,2)

      return
      end 
