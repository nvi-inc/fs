      subroutine lxprm
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
      integer nchar
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
      data jparm/5/
      data n/1/ 
C 
C 
700   if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 710
C
C  WRITE OUT TOTAL NUMBER OF PARMS SPECIFIED
C
      if (nump.eq.0) goto 705
      write(luusr,9700) (nparm(i),i=1,nump)
9700  format("parm = "4(i2,","),i2)
      goto 1700
705   call po_put_c(' none specified')
      goto 1700
C
710   ich = ieq+1
C
C  Determine the PARMS and the number of PARMS specified
C
      nump=0
      call ifill_ch(nparm,1,10,' ')
      do n= 1,jparm
         call gtprm(ibuf,ich,nchar,1,parm,ierr)
C
C  Check to see if any more PARMs have been specified and see if they
C  are valid.
C
         if (cjchar(parm,1).eq.',') goto 1700
         if (ierr.eq.0.and.iparm(1).gt.0) goto 720
         call po_put_c('LXPRM20 - invalid parameter number')
         icode=-1
         goto 1700
C
C  Store the specified PARM into NPARM. NUMP stores the quantity
C  of PARMS specified within the 430 loop. Store the <n> values
C  that indicate the parameter number for the corresponding SCALE
C  command.
C
720      nparm(n) = iparm(1)
         nscale(n) = nparm(n)
         nump = nump+1
      end do
C
      do i=1,jparm
        smin(i) = 0.0
        smax(i) = 0.0
        sdelta(i) = 0.0
      end do
C
1700  continue
      return
      end
