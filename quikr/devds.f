      subroutine devds(ip,iclcm,nsub)
C                         ! <880620.1429>
C 
C   DEVDS displays data from direct device communications 
C 
C     INPUT VARIABLES:
      dimension ip(1) 
C        IP(1)  - class number of buffer from MATCN (or IBCON)
C        IP(2)  - # records in class
C        IP(3)  - error return from MATCN 
C 
C     OUTPUT VARIABLES: 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
      include '../include/fscom.i'
C 
C     CALLING SUBROUTINES: MA, IB 
C     CALLED SUBROUTINES: character utilities 
C 
C  LOCAL VARIABLES
C     NSUB - subroutine number in segment 
C            8 = ANTENNA
      integer*2 ibuf(256),ibuf2(256),icr,ilf
C               - input class buffer, output display buffer 
C        ILEN   - length of buffers, chars
C        NCH    - character counter 
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC 
      equivalence (reg,ireg(1)) 
C 
C 5.  INITIALIZED VARIABLES 
      data ilen/512/,ilen2/512/
C 
C 6.  PROGRAMMER: NRV 
C     LAST MODIFIED: 800831 
C 
C     1. Get RMPAR parameters and check for errors from our I/O request.
C 
      iclass = ip(1)
      ncrec = ip(2) 
      ierr = ip(3)
      if (ierr.lt.0 .or. iclass.eq.0 .or. iclcm.eq.0) return
C 
C     2. Get class buffer with command in it.  Set up first part
C     of output buffer.  Get first buffer from MATCN. 
C 
      ireg(2) = get_buf(iclcm,ibuf2,-ilen2,idum,idum)
C 
      nchar = min0(ireg(2),ilen2) 
      nch = iscn_ch(ibuf2,1,nchar,'=')
      nch = ichmv_ch(ibuf2,nch,'/') 
C                   Put / to indicate a response
C 
      call pchar(icr,1,13)
      call pchar(ilf,1,10)
      do i=1,ncrec
        if (i.ne.1) nch=ichmv_ch(ibuf2,nch,',') 
C                   If not first parm, put comma before 
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = ireg(2) 
        if(nchar.gt.0) then
C                   Delete CR and LF from the ends
          do while(ichcm(ibuf,nchar,icr,1,1).eq.0.or.
     &             ichcm(ibuf,nchar,ilf,1,1).eq.0.or.
     &             ichcm(ibuf,nchar,  0,1,1).eq.0)
             nchar=nchar-1
             if(nchar.lt.1) goto 200
          enddo
        endif
200     continue
        if (nsub.ne.8) then
           nchar=max(0,min(nchar-2,ilen2-(nch-1)))
           nch = ichmv(ibuf2,nch,ibuf(2),1,nchar) 
C                   For MA and IB responses, skip word 1
        else
           nchar=max(0,min(nchar,ilen2-(nch-1)))
           nch = ichmv(ibuf2,nch,ibuf,1,nchar)
C                   For antenna responses, use word 1 
        endif
C                   Move buffer contents into output list 
      enddo
C 
      nch = nch - 1 
      iclass = 0
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
C 
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0
      call char2hol('qb',ip(4),1,2)
      ip(5) = 0 
      return
      end 
