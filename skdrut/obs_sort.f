      subroutine obs_sort(luscn)
C OBS_SORT sorts the index array for observations by time.
C 000606 nrv New. Algorithm from Numerical Methods.
C 000616 nrv Add calls to SNAME to generate scan names.
C 000725 nrv Check NOBS and don't try to sort 0 or 1 obs!
C 001109 nrv scan_name is character now.
C 010102 nrv Stop if error parsing an observation.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C Input
      integer luscn
C Local
      integer*2 itim1(6),itim2(6),name(5),namep(5)
      integer is,ic1,ix,j,i,ich,irec,ic11,ic2,idum
      integer idayr,ihr,imin,idayr_next,ihr_next,imin_next
      integer ias2b,ichmv
      logical kearl

C  1. Sort the obs.

      if (nobs.ge.2) then ! sort
        do j=2,nobs
          irec=iskrec(j)
          ich=1
          do ix=1,5 ! the time is in the 5th field 
            CALL GTFLD(lskobs(1,iskrec(j)),ICH,IBUF_LEN*2,IC11,IC2)
          enddo
          if (ic11.le.0) then
            write(luscn,'("OBS_SORT01 - Error parsing observation ",i5,
     .      100a2)') iskrec(j),(lskobs(is,iskrec(j)),is=1,100)
            stop
          endif
          idum= ichmv(itim1,1,lskobs(1,iskrec(j)),ic11,11)
          do i=j-1,1,-1
            ich=1
            do ix=1,5 ! the time is in the 5th field 
              CALL GTFLD(lskobs(1,iskrec(i)),ICH,IBUF_LEN*2,IC11,IC2)
            enddo
            if (ic11.le.0) then
            write(luscn,'("OBS_SORT02 - Error parsing observation ",i5,
     .        100a2)') iskrec(i),(lskobs(is,iskrec(i)),is=1,100)
              stop
            endif
            idum= ichmv(itim2,1,lskobs(1,iskrec(i)),ic11,11)
            if (.not.kearl(itim1,itim2)) goto 10
            iskrec(i+1) = iskrec(i)
          enddo
          i=0
10        iskrec(i+1)=irec
        enddo
      endif ! sort

C  2. Generate scan names

      if (nobs.eq.0) return
      call ifill(namep,1,10,oblank)
      call ifill(name ,1,10,oblank)
      irec=iskrec(1)
      ich=1
      do ix=1,5 ! the time is in the 5th field 
        CALL GTFLD(lskobs(1,irec),ICH,IBUF_LEN*2,IC1,IC2)
      enddo
      IDAYR = IAS2B(lskobs(1,irec),IC1+2,3)
      IHR = IAS2B(lskobs(1,irec),IC1+5,2)
      iMIN = IAS2B(lskobs(1,irec),IC1+7,2)
      if (nobs.le.2) return
      do i=2,nobs
        irec=iskrec(i)
        ich=1
        do ix=1,5 ! the time is in the 5th field 
          CALL GTFLD(lskobs(1,irec),ICH,IBUF_LEN*2,IC1,IC2)
        enddo
        IDAYR_next = IAS2B(lskobs(1,irec),IC1+2,3)
        IHR_next = IAS2B(lskobs(1,irec),IC1+5,2)
        iMIN_next = IAS2B(lskobs(1,irec),IC1+7,2)
        call sname(idayr,ihr,imin,namep,name,
     .     idayr_next,ihr_next,imin_next)   
        call hol2char(name,1,9,scan_name(iskrec(i-1)))
C       idum= ichmv(scan_name(1,iskrec(i-1)),1,name,1,9)
        idayr= idayr_next
        ihr= ihr_next
        imin= imin_next
        idum= ichmv(namep,1,name,1,9)
      enddo
C     Last scan
      idayr_next = -1
      call sname(idayr,ihr,imin,namep,name,
     .     idayr_next,ihr_next,imin_next)   
C     idum= ichmv(scan_name(1,iskrec(nobs)),1,name,1,9)
      call hol2char(name,1,9,scan_name(iskrec(i-1)))

      return
      end
