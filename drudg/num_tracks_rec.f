      integer function num_tracks_rec(itras)
      include '../skdrincl/skparm.ftni'

C  INPUT:
      integer itras(2,2,max_headstack,max_chan)
C             Mark III # track assignments from schedule
C             sub-array for only this code, this station
! local
      integer isb,ibit,ihd,ichan,it
      
      num_tracks_rec=0
      do isb=1,2
        do ibit=1,2
          do ihd=1,max_headstack
            do ichan=1,max_chan
              it = itras(isb,ibit,ihd,ichan)
              if (it.ne.-99) then
                 num_tracks_rec=num_tracks_rec+1
              endif
            enddo
          enddo
        enddo
      enddo

      end

