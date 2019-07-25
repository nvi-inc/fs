      subroutine ctemp(ip,nsub)
C  set cal temp c#870115:04:44#
C 
C     Set and display the cal temperature 
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
      data ilen/40/ 
C 
      indtmp = mod(nsub,10)
C                   Pick up the proper index for the temp 
      iclcm = ip(1) 
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum) 
      nchar = ireg(2) 
      ieq = iscn_ch(ibuf,1,nchar,'=') 
      if (ieq.eq.0) goto 500
C 
C 
C     2. Parse the command: CALTEMP=<value> 
C 
      ich = ieq+1 
      ic1 = ich 
      call gtprm(ibuf,ich,nchar,2,parm,ierr)  
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 215 
      if (cjchar(parm,1).ne.'*') goto 211
      t = caltmp(indtmp)
C                   Pick up the temp from COMMON
      goto 300
211   ierr = -101 
C                   There is no default for the temperature 
      goto 990
C 
215   t = parm
      if (ierr.eq.0) goto 300 
      ierr = -201 
      goto 990
C 
C 
C     3. Put the value into common. 
C 
300   caltmp(indtmp) = t
C 
      ierr = 0
C 
990   ip(1) = 0 
      ip(2) = 0 
      ip(3) = ierr
      call char2hol('qc',ip(4),1,2)
      return
C 
C     5. Return the cal temp for display
C 
500   nch = ichmv_ch(ibuf,nchar+1,'/')
      nch = nch + ir2as(caltmp(indtmp),ibuf,nch,5,1)
C 
      iclass = 0
      nch = nch - 1 
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1 
      ip(3) = 0 
      call char2hol('qc',ip(4),1,2)

      return
      end 
