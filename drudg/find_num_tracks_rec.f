      subroutine find_num_tracks_rec(itras,ntracks_obs,ntracks_rec_mk5)
      include '../skdrincl/skparm.ftni'

C  INPUT:
      integer itras(2,2,max_headstack,max_chan)
C             Mark III # track assignments from schedule
C             sub-array for only this code, this station
      integer ntracks_obs,ntracks_rec_mk5
! local
      integer isb,ibit,ihd,ichan,it
      integer i
      
      ntracks_obs=0
      do isb=1,2
        do ibit=1,2
          do ihd=1,max_headstack
            do ichan=1,max_chan
              it = itras(isb,ibit,ihd,ichan)
              if (it.ne.-99) then
                 ntracks_obs=ntracks_obs+1
              endif
            enddo
          enddo
        enddo
      enddo
! At this point have the number of tracks observed
      ntracks_rec_mk5=8                 !can only record in units of 8,16, 32,64
      do i=1,4
         if(ntracks_obs .le.ntracks_rec_mk5) goto 5
         ntracks_rec_mk5=ntracks_rec_mk5*2
      end do
5     continue


      end

