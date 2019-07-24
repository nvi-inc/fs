      subroutine lxout
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
      integer answer, trimlen, ichmv
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
C  Check for a specified OUTPUT LU. If no OUTPUT LU was specified, then
C  write out the OUTPUT file name.
C
100   if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 105
      if (iterm.ne.1) goto 102
        outbuf='output= '
        call ib2as(ludsp,answer,1,4)
        call hol2char(answer,1,4,outbuf(9:))
        call po_put_c(outbuf)
      goto 1700
102   outbuf='output=' // namfc
      call po_put_c(outbuf)
      goto 1700
C
C  Determine whether the OUTPUT command is an LU or an output file
C  by calling GTPRM with the IERR parameter.
C
105   continue
      ich= ieq+1
      ich1=ich
      call gtprm(ibuf,ich,nchar,1,parm,ierr)
      if (ierr.eq.-1) goto 150
      if (cjchar(iparm,1).ne.',') goto 110
      ludsp=luusr
      goto 120
110   continue
      ludsp=iparm(1)
120   iterm=1
      call fmpclose(jdcb,ierr)
C
C Store one blank in L6 for single spacing.
C
      call char2hol(' ',l6,1,1)
C
C If LUDSP is a printer, a one is stored in L6 which will start the
C printer on a new page.
C
      if (ludsp.eq.6) call char2hol(' ',l6,1,1)
      goto 1700
C
C Let's get the output file name.  If the NAMR is valid, call LXCRT to
C create it.
C
150   istrc=ich1
      call ifill_ch(namf,1,20,' ')
      id = ichmv(namf,1,ibuf,istrc,ich-istrc-1)
      call lower(namf,ich-istrc-1)
155   call lxcrt
      if (icode.ne.-1) goto 160
      ludsp=luusr
      goto 1700
160   iterm=0
C
1700  continue
      return
      end
