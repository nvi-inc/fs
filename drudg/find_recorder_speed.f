      subroutine find_recorder_speed(icode,spd_rec)
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
      include 'hardware.ftni'
! passed
      integer icode                     ! current mode

! returned
      double precision spd_rec   ! speed of recorder.
! local
      double precision conv 		! conversion factor
      integer ntracks_rec_mk5
      integer nchans_obs               !Number recorded
      integer ifan_fact                 !ifan_factor

      if(km5 .or. km5p .or. km5A_piggy .or. km5P_piggy) then
        ifan_fact=max(1,ifan(istn,icode))
        call find_num_chans_rec(itras(1,1,1,1,1,istn,icode),
     >            ifan_fact,nchans_obs,ntracks_rec_mk5)
        if(km5) then
          if(km5A_piggy) ntracks_rec_mk5=32
          conv=(1./8.)     		!= 1byte/8bits
          spd_rec=(ntracks_rec_mk5/ifan_fact)*samprate(icode)*conv
        else if(km5p) then
          if(km5P_piggy) nchans_obs=32/ifan_fact
          conv=(9./8.)*(1./8.)     !=(  (8+1parity)/8bits * bits_per_byte
          spd_rec=nchans_obs*samprate(icode)*conv
        endif
      else if(kk4) then
         conv = 55.389387393d0 ! counts/sec
         spd_rec = conv*samprate(icode)/4.0d0 ! 55, 110, or 220 cps
      else if(ks2) then
         spd_rec=1
      endif

      return
      end
