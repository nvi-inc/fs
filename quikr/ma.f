      subroutine ma(ip,nsub)
C  mat and antenna command 
C 
C    MA transmits a buffer to MATCN or to ANTCN (OVRO ONLY) 
C 
C     INPUT VARIABLES:
C 
      dimension ip(1) 
C        IP(1)  - class number of input parameter buffer. 
C 
C     OUTPUT VARIABLES: 
C 
C        IP(1) - CLASS
C        IP(2) - # REC
C        IP(3) - ERROR
C        IP(4) - who we are 
C 
C    COMMON BLOCKS USED 
C 
      include '../include/fscom.i'
C 
C     CALLED SUBROUTINES: CHARACTER ROUTINES
C 
C   LOCAL VARIABLES 
C 
C     NSUB - which command are we processing
C            1=MAT, 8=ANTENNA 
C        NCHAR  - number of characters in buffer
C        NCH    - character counter 
C        ICOM    - character index of comma 
      integer*2 ibuf(50),ibuf2(50) 
C               - class buffer
C               - output buffer for transmission
C        ILEN   - length of IBUF, chars 
      dimension ireg(2) 
      integer get_buf
C               - registers from EXEC calls 
      character*1 cjchar
C 
      equivalence (reg,ireg(1)) 
C 
C    INITIALIZED VARIABLES
C 
      data ilen/100/
C 
C   PROGRAMMER: NRV 
C     LAST MODIFIED: 800831 
C 
C 
C     1. Get the class buffer.  Messages for the MAT or for the antenna 
C     may be strung together, separated by commas.
C     Each set of characters between
C     commas is sent as a separate record in the class buffer.
C     Scan for a comma and write it out.
C
      iclcm = ip(1)
      if (iclcm.ne.0) goto 110
100   ierr = -1
      goto 990
110   ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 100
C                   If no parameters, get mad!
C
      nrec = 0
      iclass = 0
      ifc = 1+ieq
      call upper(ibuf,1,nchar)
C      
200   continue
      ichr=ifc
 202  continue
      if(ichr.le.nchar) then
         if(cjchar(ibuf,ichr).eq.'\\') then
            do i=ichr,nchar-1
               call pchar(ibuf,i,jchar(ibuf,i+1))
            enddo
            nchar=nchar-1
         else if(cjchar(ibuf,ichr).eq.',') then
            icom=ichr
            goto 203
         endif
         ichr=ichr+1
         goto 202
      else
         icom=0
      endif
 203  continue
      if (icom.eq.0) icom = nchar + 1
      nch = icom - ifc
      if (nch.le.0) goto 210
C                   If there's nothing left, quit
      call pchar(idum,2,9)
      nenq = iscnc(ibuf,ifc,icom-1,9)
C                   Scan for a tab character
      if (nenq.ne.0) idumm1 = ichmv(ibuf,nenq,o'5',2,1)
C                   If we found one, substitute the enq character
      idumm1 = ichmv(ibuf2(2),1,ibuf,ifc,icom-1)
C                   Move characters to output buffer starting at first
C                   character of this message up to just before comma.
      if (nsub.eq.8) goto 205
      ibuf2(1) = 5
C                   Set up for MAT mode 5
      nch = nch + 2
      call put_buf(iclass,ibuf2,-nch,'fs','  ')
      goto 220
205   call put_buf(iclass,ibuf2(2),-nch,'fs','  ')
C                   For ANTCN, don't send the mode
220   nrec = nrec + 1
      ifc = icom + 1
C                   Start next scan after the comma
      if (ifc.gt.nchar) goto 210
C                   If we are beyond the end, quit
      goto 200
C
210   ierr = 0
      if (iclass.ne.0) goto 980
      ierr = -1
      goto 990
980   if (nsub.eq.1) call run_matcn(iclass,nrec)
      if (nsub.eq.8) then
        call fs_get_idevant(idevant)
        if (ichcm_ch(idevant,1,'/dev/null ').ne.0) then
          call run_prog('antcn','wait',4,iclass,nrec,idum,idum)
        else
          ierr= -301
          goto 990
        endif
      endif
      call rmpar(ip)
      call devds(ip,iclcm,nsub)
      return
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qb',ip(4),1,2)
      return
      end 
