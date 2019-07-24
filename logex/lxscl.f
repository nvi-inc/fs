      subroutine lxscl
C
C  COMMON BLOCKS USED:
C 
      include '../include/fscom.i'
      include 'lxcom.i'
C 
C      CALLING SUBROUTINES: 
C 
C      File manager package routines
C      Character manipulation routines
C 
C  LOCAL VARIABLES: 
C 
      character*79 outbuf
      integer answer, nchar, trimlen
      character cjchar
      dimension iparm(2)
C 
      equivalence (parm,iparm(1))
C 
C     N - the variable that indicates the parameters the min & max
C         SCALE values apply to.
C
C  INITIALIZED VARIABLES:
C
      data n/1/ 
C 
C 
C Scan for an equals sign.  If no equals sign, write out SCALE values.
C
800   if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 810
C
C  Write out total number of min, max, n, llogx values specified
C
      write(luusr,9800)
     & (smin(n),smax(n),nscale(n),llogx(n),sdelta(n),n= 1,nump)
9800  format(1x,"scale="f13.8","f13.8","i1","a2,",",f13.8)
      goto 1700
C
810   ich = ieq+1
C
C Retrieve the SMIN value
C
      call gtprm(ibuf,ich,nchar,2,parm,id)
      s1 = parm
C
C Retrieve the SMAX value
C
      call gtprm(ibuf,ich,nchar,2,parm,id)
      s2 = parm
C
C Retrieve the N value
C
      call gtprm(ibuf,ich,nchar,1,parm,id)
      n=iparm(1)
      if (cjchar(parm,1).eq.','.and.nump.gt.0) n=nscale(1)
C
C Retrieve the dB scale
C
      call gtprm(ibuf,ich,nchar,0,parm,id)
C
C Retrieve the DELTA value
C
      call gtprm(ibuf,ich,nchar,2,parm,id)
      if (cjchar(iparm,1).eq.',') then
        de=0.0
      else
        de = parm
      endif
C
C  Determine whether the min is less than the max
C
      if (s1.le.s2) goto 830
C
      call po_put_c('LXSCL40 - min greater than max.')
      icode=-1
      goto 1700
C
830   do i=1,nump
       if (nscale(i).eq.n) goto 850
      end do
      outbuf='LXSCL30 - invalid parameter number: '
      call ib2as(n,answer,1,4)
      call hol2char(answer,1,4,outbuf(37:))
      call po_put_c(outbuf)
      icode=-1
      goto 1700
850   smin(i) = s1
      smax(i) = s2
      llogx(i) = iparm(1)
      sdelta(i)=de
C
C Check for a dB scale
C
      if (llogx(i).ne.2Hdb) call char2hol('  ',llogx(i),1,2)
C
1700  continue
      return
      end
