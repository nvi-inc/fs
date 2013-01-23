      subroutine check_dbbc_setup(icode)
! Some simple checking of dbbc.
! This checks to make sure that the lo frequencys for each IF are the same
! and that the filter used is the same.
! The first IF "A" connects to BBC01-BBC04. The lo frequencies of these BBCs should be the same.
! Also the filter frequencies should be the same. 
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'

! Local
      integer if_num
      integer 


      do if_num=1,4     !this is over Ifs
        ib0=0
        ib_beg=(if_num-1)*4+1
        ib_end=if_num*4
        DO ib=ib_beg, ib_end 
          if(ibbc_present(ib,istn,icode) .eq. -1) goto 100  !quick exit
          if(ib0  .eq. 0) then
            ib0=ib
          else           
            if(flo(ib0) .ne. flo(ib)) then
               write(luscn, '("DBBC_error: For BBCs ",2i4,
     >                "lo frequencies differ",2f8.2)')
     >             ib0, ib, flo(ib0), flo(ib)
              endif 
            endif
            if(ibbc_filter(ib0) .ne. ibbc_filter(ib0) then
               write(luscn,'("DBBC_error: For BBCs ",2i4,
     >           "filters differ ", 2i8)') 
     >             ib0, ib, ibbc_filter(ib0), ibbc_filter(ib)
            endif                  
          endif 
100       continue       !quick exit
        end do
      end do

