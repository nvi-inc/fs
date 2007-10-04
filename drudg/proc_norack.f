      subroutine proc_norack(icode)
! write out comments for no rack case.
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'

! passed
      integer icode

! functions
      integer ib2as     !lnfch
      integer ir2as
      integer ichmv_ch
! local
      integer ichan
      integer nch
      integer ic
      real fr,rfvc  !VC frequencies

      integer igig
      integer Z4000,Z100
      double precision DRF,DLO

      data Z4000/Z'4000'/,Z100/Z'100'/

      write(lu_outfile,'(a)')'"channel  sky freq  lo freq  video'
      DO ichan=1,nchan(istn,icode) !loop on channels
        cbuf='"'
        nch=6
        ic=invcx(ichan,istn,icode) ! channel number
        nch = nch + ib2as(ic,ibuf,nch,Z4000+2*Z100+2)
        nch = nch + 3
        fr = FREQRF(ic,istn,ICODE) ! sky freq
        if (freqrf(ic,istn,icode).gt.100000.d0) then
          igig=freqrf(ic,istn,icode)/100000.d0
          nch=nch+ib2as(igig,ibuf,nch,1)
          fr=freqrf(ic,istn,icode)-igig*100000.d0
        endif
        NCH = nch + IR2AS(fr,IBUF,nch,8,2)
        nch = nch + 3
        fr = abs(FREQLO(ic,istn,ICODE)) ! sky freq
        if (abs(freqLO(ic,istn,icode)).gt.100000.d0) then
          igig=abs(freqLO(ic,istn,icode))/100000.d0
          nch=nch+ib2as(igig,ibuf,nch,1)
          fr=abs(freqLO(ic,istn,icode))-igig*100000.d0
        endif
        NCH = nch + IR2AS(fr,IBUF,nch,8,2)
        nch = nch + 3
        DLO = freqlo(ic,istn,icode) ! lo freq
        DRF = abs(FREQRF(ic,istn,ICODE)) ! sky freq
        rFVC = abs(DRF-DLO)   ! BBCfreq = RFfreq - LOfreq
        NCH = nch + IR2AS(rFVC,IBUF,nch,8,2)
        if (DRF-DLO .lt. 0.d0) nch = ichmv_ch(ibuf,nch+1,"LSB")
        call lowercase_and_write(lu_outfile,cbuf)
      enddo ! loop on channels

      end
