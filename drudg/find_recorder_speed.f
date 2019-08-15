      subroutine find_recorder_speed(icode,spd_rec,kskd)
      include 'hardware.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
! passed
      integer icode                     ! current mode
      logical kskd                      ! do we have a sked file? need to get speed for Mark5A or Mark5P

! 2013Sep19  JMGipson made sample rate station dependent
!

! returned
      double precision spd_rec   ! speed of recorder.
! local
      double precision conv 		! conversion factor
      integer ntracks_rec_mk5
      integer nchans_obs               !Number recorded
      integer ifan_fact                 !ifan_factor
      integer ipass

      ipass=1

      if(Km5disk .or. km5A_piggy .or. km5P_piggy) then
        if(kskd) then
          ifan_fact=max(1,ifan(istn,icode))
          call find_num_chans_rec(ipass,istn,icode,
     >            ifan_fact,nchans_obs,ntracks_rec_mk5)
          if(km5p .or. Km5P_piggy) then
!            if(km5P_piggy) nchans_obs=32/ifan_fact
            conv=(9./8.)*(1./8.)     !=(  (8+1parity)/8bits * bits_per_byte
            nchans_obs=32         !always record 32 tracks for Mark5P.
            spd_rec=nchans_obs*samprate(istn,icode)*conv
          else
            conv=(1./8.)     		!= 1byte/8bits
            spd_rec=ntracks_rec_mk5*samprate(istn,icode)*conv
          endif
	  spd_rec=spd_rec/ifan_fact
        endif
      else if(kk4) then
         if(kskd) then
           conv = 55.389387393d0 ! counts/sec
           spd_rec = conv*samprate(istn,icode)/4.0d0 ! 55, 110, or 220 cps
          else
            spd_Rec=1.
          endif
      else if(ks2) then
         spd_rec=1
      endif

      return
      end
