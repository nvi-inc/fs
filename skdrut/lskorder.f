      SUBROUTINE LSKORDER(itype)

C  This routine time orders the observations in LSKOBS.
C
C History
C 980217 nrv New. Removed from VOB1INP and SREAD (drudg).

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C INPUT
      integer itype ! 1=just check the newest (last) scan
C                     2=check 'em all
C
C  CALLED BY: VOB1INP (itype=1), SREAD (itype=2)
C
C  LOCAL:
      integer irec,i,idum,ipnt,irec_save
      integer*2 itim1(6),itim2(6)
      integer ic2,ic11,ic12,ich
      logical kcheck,kearl
      integer ichmv

      kcheck=.true.
      irec=nobs
      do while (irec.gt.1.and.kcheck) ! check backwards
        irec_save=irec
C       Find the time field by skipping over 4 fields
        ich=1
        do i=1,5 ! want the 5th field of last scan
          CALL GTFLD(lskobs(1,iskrec(irec)),ICH,IBUF_LEN*2,IC11,IC2)
        enddo
        idum= ichmv(itim1,1,lskobs(1,iskrec(irec)),ic11,11)
        ich=1
        do i=1,5 ! want the 5th field of next-to-last scan
          CALL GTFLD(lskobs(1,iskrec(irec-1)),ICH,IBUF_LEN*2,IC12,IC2)
        enddo
        idum= ichmv(itim2,1,lskobs(1,iskrec(irec-1)),ic12,11)
C
        do while (kearl(itim1,itim2).and.irec.gt.1)  !out of order
C       Check time order and bubble this scan up into place.
C         Swap pointers
          ipnt = iskrec(irec-1)
          iskrec(irec-1) = iskrec(irec)
          iskrec(irec) = ipnt
C         Get new time fields 
C         idum= ichmv(itim1,1,lskobs(1,iskrec(irec)),ic12,11)
          irec = irec-1
          if (irec.gt.1) then ! continue
            ich=1
            do i=1,5 ! want the 5th field 
              CALL GTFLD(lskobs(1,iskrec(irec-1)),ICH,IBUF_LEN*2,IC12,
     .               IC2)
            enddo
            idum= ichmv(itim2,1,lskobs(1,iskrec(irec-1)),ic12,11)
          endif
        end do  !out of order
        irec=irec_save-1
        if (itype.eq.1) kcheck=.false. ! we're done
      enddo ! check backwards

      return
      end
