      subroutine obs_sort(luscn)
C OBS_SORT sorts the index array for observations by time.
C 000606 nrv New. Algorithm from Numerical Methods.
C 000616 nrv Add calls to SNAME to generate scan names.
C 000725 nrv Check NOBS and don't try to sort 0 or 1 obs!
C 001109 nrv scan_name is character now.
C 010102 nrv Stop if error parsing an observation.
C 03July11 JMG Modified to use sktime.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C Input
      integer luscn
C Local
      integer*2 itim1(6),itim2(6),name(5),namep(5)
      integer j,i,irec,idum
      integer idayr,ihr,imin,idayr_next,ihr_next,imin_next
      integer ias2b,ichmv
      logical kearl
      character*12 ctim1,ctim2
      equivalence (itim1,ctim1),(itim2,ctim2)

C  1. Sort the obs.

      write(luscn,'("OBS_SORT00 - Sorting scans by time.")')
      if (nobs.ge.2) then ! sort
        do j=2,nobs
          irec=iskrec(j)
          call sktime(lskobs(1,iskrec(j)),itim1)
          do i=j-1,1,-1
            call sktime(lskobs(1,iskrec(i)),itim2)
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
      call sktime(lskobs(1,irec),itim1)
      IDAYR = IAS2B(itim1,3,3)
      IHR   = IAS2B(itim1,6,2)
      iMIN  = IAS2B(itim1,8,2)
      if (nobs.le.2) return
      do i=2,nobs
        irec=iskrec(i)
        call sktime(lskobs(1,irec),itim1)
        IDAYR_next = IAS2B(itim1,3,3)
        IHR_next   = IAS2B(itim1,6,2)
        iMIN_next  = IAS2B(itim1,8,2)
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
