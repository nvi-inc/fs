      subroutine drivem(idcb,name,ip,ierr_num,indxtp)
      integer idcb(2),indxtp,ierr_num
      character*(*) name
      integer*4 ip(5)
c
      integer ierr,idum,ilen,ich,ic1,ic2,line
      integer*2 ibuf(50)
c
      include '../include/fscom.i'
c
      call fmpopen(idcb,name,ierr,'r',idum)
      if (ierr.lt.0) then
        call logit7ci(0,0,0,1,ierr_num,'bo',ierr)
        goto 995
      endif
c
      line=0
      call driveall(idcb,ibuf,ip,ierr_num-1,line,indxtp)
      if(ip(3).ne.0) goto 990
c
C LINE #1 TAPE STARTUP PARAMETER (TACC) - iacttp
c
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.le.0) goto 990
      iacttp(indxtp) = ias2b(ibuf,ic1,ic2-ic1+1)
      if (iacttp(indxtp).lt.0) goto 990
c
      call fmpclose(idcb,ierr)
      return

 990  continue
      call logit7ci(0,0,0,1,ierr_num-1,'bo',line)
 995  continue
      ip(3)=-1
      return
      end
