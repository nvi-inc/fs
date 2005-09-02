      subroutine freq_init
! intilize the frequency part
C   COMMON BLOCKS USED
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
! local
      integer ic,is,iv,i,ix

      NCODES = 0
      do ic=1,max_frq
        cmode_cat(ic)=" "
        do is=1,max_stn
          do iv=1,max_chan
            ibbcx(iv,is,ic)=0
            freqrf(iv,is,ic)=0.d0
          enddo
          ntrakf(is,ic)=0
          do i=1,max_band
            trkn(i,is,ic)=0.0
            ntrkn(i,is,ic)=0
            nfreq(i,is,ic)=0
          enddo
        enddo
        lcode(ic)=0
        do ix=1,max_band
          do is=1,max_stn
            wavei(ix,is,ic) = 0.0
            bwrms(ix,is,ic) = 0.0
          enddo
        enddo
      enddo
      return
      end



