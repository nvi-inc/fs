      SUBROUTINE SKORDER

C  This routine checks and fixes the time ordering of observations
C  in the LSKOBS array.
C  Call after VOB1INP or after the $SKED section was read.
C
C History
C 991020 nrv New. Extracted from VOB1INP.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
C  OUTPUT:

C  CALLED BY: SKOPN, FDRUDG
C
C  LOCAL:
      integer idum,irec,ipnt,ireclast
      integer*2 itim1(6),itim2(6)
      integer i,ic2,ic11,ic12,ich
      logical kearl,kout
      integer ichmv

C  Order the index array, iskrec, in time order.
C  The time field in the array LSKOBS is the 5th one.
C
      ireclast = nobs
      kout=.true. 
      do while (ireclast.gt.1) ! there are still obs out of order
        irec=ireclast ! start at the last one still in order
        ich=1
        do i=1,5 ! want the 5th field 
          CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC11,IC2)
        enddo
        ich=1
        do i=1,5 ! want the 5th field 
          CALL GTFLD(lskobs(1,iskrec(irec-1)),ICH,IBUF_LEN*2,IC12,IC2)
        enddo
        idum= ichmv(itim1,1,lskobs(1,iskrec(irec)),ic11,11)
        idum= ichmv(itim2,1,lskobs(1,iskrec(irec-1)),ic12,11)
        do while (irec.gt.2)  
          if (kearl(itim1,itim2)) then !out of order
C           Swap pointers
            ipnt = iskrec(irec-1)
            iskrec(irec-1) = iskrec(irec)
            iskrec(irec) = ipnt
          endif
C         Get new time fields 
C         Get time field of the now-correct last record.
          irec = irec-1
C         idum= ichmv(itim1,1,lskobs(1,iskrec(irec)),ic12,11)
          idum= ichmv(itim1,1,itim2,1,11)
          ich=1
          do i=1,5 ! want the 5th field 
            CALL GTFLD(lskobs(1,iskrec(irec-1)),ICH,IBUF_LEN*2,IC12,IC2)
          enddo
          idum= ichmv(itim2,1,lskobs(1,iskrec(irec-1)),ic12,11)
        end do  !out of order
        ireclast=ireclast-1 
      enddo

      return
      end
