      subroutine find_num_chans_rec(ipass,istn,icode,
     > ifan,nchan_obs,nchan_rec_mk5)
      include '../skdrincl/skparm.ftni'

      integer itras

C  INPUT:
      integer ipass,istn,icode
      integer ifan                                 ! fan out factor.
! returned.
      integer nchan_obs,nchan_rec_mk5
! local
      integer isb,ibit,ihd,ichan,it
      integer i
      
      nchan_obs=0
      do isb=1,2
        do ibit=1,2
          do ihd=1,max_headstack
            do ichan=1,max_chan
              it = itras(isb,ibit,ihd,ichan,ipass,istn,icode)
              if (it.ne.-99) then
                 nchan_obs=nchan_obs+1
              endif
            enddo
          enddo
        enddo
      enddo
! At this point have the number of tracks observed
      nchan_rec_mk5=8                 !can only record in units of 8,16, 32,64
      do i=1,4
         if(nchan_obs*ifan .le.nchan_rec_mk5) goto 5
         nchan_rec_mk5=nchan_rec_mk5*2
      end do
5     continue

      end

