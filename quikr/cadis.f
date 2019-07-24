      subroutine cadis(ip,iclcm)
C  display cable cal c#870115:04:36#
C 
C 1.  CADIS PROGRAM SPECIFICATION 
C 
C 1.1.   CADIS displays data from the cable cal 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from IBCON 
C        IP(2)  - number of records in class
C        IP(3)  - error return from IBCON 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - error
C        IP(2) - class
C        IP(3) - number of records
C        IP(4) - who we are 
C 
C 2.2.   COMMON BLOCKS USED 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: character utilities 
C 
C 3.  LOCAL VARIABLES 
      integer*2 ibuf(30),ibuf2(30)
C               - input class buffer, output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
C 
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/60/ 
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED:   800220 
C 
C     PROGRAM STRUCTURE 
C 
C     1. First check error return from IBCON.  If not 0, get out
C     immediately.
C 
C 
      iclass = ip(1)
      ierr = ip(3)
      nrec = 0
C 
      if (ierr.lt.0) goto 990 
      if (iclass.eq.0.or.iclcm.eq.0) goto 990 
C 
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from IBCON. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen,idum,idum)
      nchar = ireg(2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      if (nch.eq.0) nch = nchar+1 
C                   If no "=" found, position after last character
      nch = ichmv(ibuf2,nch,2H/ ,1,1) 
C                   Put / to indicate a response
C 
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      nchar = ireg(2) 
      ich = 4 
      nchar=nchar-1  ! remove always present lf
      if(jchar(ibuf,nchar).eq.13) nchar=nchar-1 !remove CR if present
      call gtfld(ibuf(2),ich,nchar-2,ic1,ic2) 
      if(ic1.gt.0.and.ic2-ic1+1.ge.1) then
        nch = ichmv(ibuf2,nch,ibuf(2),ic1,ic2-ic1+1)
C                   Skip the " S " before the number
C                   Move buffer contents into output list 
      cablev = das2b(ibuf(2),ic1,ic2-ic1+1,ierr)
C                   Don't check error return
      else
        cablev = 0.0
      endif
      call fs_set_cablev(cablev)
C                   Store current cable value in COMMON 
C 
C 
C     5. Now send to buffer back to BOSS
C 
      iclass = 0
      if (ierr.lt.0) goto 900 
      nch = nch - 1 
      call put_buf(iclass,ibuf2,-nch,2Hfs,0)
900   ip(1) = iclass
      ip(2) = 1 
      ip(3) = ierr
      call char2hol('qy',ip(4),1,2)

990   return
      end 
