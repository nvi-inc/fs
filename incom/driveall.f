      subroutine driveall(idcb,ibuf,ip,ierr_num,line,indxtp)
      integer idcb(2),indxtp,ierr_num,line
      integer*2 ibuf(50)
      integer*4 ip(5)
c
      integer ierr,ilen,ich,ic1,ic2
      character*4 yesno
c
      include '../include/fscom.i'
c
C LINE #1 MAX TAPE SPEED - imaxtpsd
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if(ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      isp = ias2b(ibuf,ic1,ic2-ic1+1)
C
      if (isp.eq.360) then
        index = -2
      else if (isp.eq.330) then
        index = -1
      else if (isp.eq.270) then
        index = 7
      else
	goto 990
      endif
      imaxtpsd(indxtp) = index ! invalid speed given
      call fs_set_imaxtpsd(imaxtpsd,indxtp)
C LINE #2 SCHEDULE TAPE SPEED - iskdtpsd
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if(ierr.lt.0) goto 990
      ich = 1
      call gtfld(ibuf,ich,ilen,ic1,ic2)
      if (ic1.eq.0) goto 990
      isp = ias2b(ibuf,ic1,ic2-ic1+1)
      if (isp.eq.360) then
         index = -2
      else if (isp.eq.330) then
         index = -1
      else if (isp.eq.270) then
         index = 7
      else
         goto 990
      endif
      iskdtpsd(indxtp) = index 
      call fs_set_iskdtpsd(iskdtpsd,indxtp)
c
c line 3 vaccum switching
C
      line=line+1
      call readg(idcb,ierr,ibuf,ilen)
      if (ierr.lt.0) goto 990
      call lower(ibuf,ilen)
      ifc=1
      call gtfld(ibuf,ifc,ilen,ic1,ic2)
      if(ic1.eq.0) goto 990
      call hol2char(ibuf,ic1,ic2,yesno)
      if(yesno.eq.'yes') then
         vacsw(indxtp)=1
      else if(yesno.eq.'no') then
         vacsw(indxtp)=0
         vac4(indxtp)=0
         call fs_set_vac4(vac4,indxtp)
      else
         goto 990   
      endif
      call fs_set_vacsw(vacsw,indxtp)
      return
c
 990  continue
      call logit7ci(0,0,0,1,ierr_num-1,'bo',line)
      ip(3)=-1
      return
      end
