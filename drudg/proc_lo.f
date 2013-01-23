      subroutine proc_lo(ix,icode,clo)
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
!      include 'bbc_freq.ftni'
! make and write out the lo command.
! on entry        
      integer icode 
      character*(*) clo
      
      integer ix	     !lo index
! functions
! functions
      integer ichmv_ch  !lnfch  
      integer ir2as
      integer mcoma
      integer ichmv
      real rpc 

! Local
      integer nch
               
      write(cbuf,'("lo=lo",a,",",f9.2,",",a1,"sb,")') 
     >         clo, freqlo(ix,istn,icode), cosb(ix,istn,icode)(1:1)
!              write(*,*) cbuf(1:25)
      call squeezeleft(cbuf,nch)  
      nch=nch+1            
      if (kvex) then ! have pol and pcal
        nch=ichmv(ibuf,nch,lpol(ix,istn,icode),1,1) ! polarization
        nch=ichmv_ch(ibuf,nch,'cp,')
        rpc = freqpcal(ix,istn,icode) ! pcal spacing
        if (rpc.gt.0.0) then ! value
          nch=nch+ir2as(rpc,ibuf,nch,5,3)
        else ! off
           nch=ichmv_ch(ibuf,nch,'off')
        endif ! value/off
        rpc = freqpcal_base(ix,istn,icode) ! pcal offset
        if (rpc.gt.0.0) then
          NCH = MCOMA(IBUF,NCH)
          nch=nch+ir2as(rpc,ibuf,nch,5,3)
        endif
      else if(kgeo) then
         nch=ichmv_ch(ibuf,nch,"rcp,1")
      endif ! have pol and pcal          
      call lowercase_and_write(lu_outfile,cbuf)
      return
      end 
