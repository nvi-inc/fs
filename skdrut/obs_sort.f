      subroutine obs_sort(luscn)
C OBS_SORT sorts the index array for observations by time.
C 000606 nrv New. Algorithm from Numerical Methods.
C 000616 nrv Add calls to SNAME to generate scan names.
C 000725 nrv Check NOBS and don't try to sort 0 or 1 obs!
C 001109 nrv scan_name is character now.
C 010102 nrv Stop if error parsing an observation.
C 03July11 JMG Modified to use sktime.
! 04Oct15  JMGipson. Completely rewritten.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/skobs.ftni'
C Input
      integer luscn
! functions
      integer julda
C Local

      integer*2 itim1(6)
      character*12 ctim1
      equivalence (itim1,ctim1)

      integer j,i,irec
      double precision jday(Max_obs)
      integer iyear,iday
      double precision rhr,rmin,rs

      integer iptr,iptr_old
      integer ndup
      character*26 lextra
      data lextra/"abcdefghijklmnopqrstuvwxyz"/

      if (nobs.eq.0) return

!  1. Sort the obs by time and then by source_name.

      do i=1,nobs
        call sktime(lskobs(1,iskrec(i)),itim1)
        read(ctim1,'(i2,i3,3(i2))') iyear,iday,rhr,rmin,rs
        if(iyear .lt. 50) then
           iyear=iyear+2000
        else
           iyear=iyear+1900
        endif
        jday(i)=julda(1,iday,iyear)+(rs+rmin*60.d0+rhr*3600.)/86400.d0
      end do

      write(luscn,'("OBS_SORT00 - Sorting scans by time.")')
      do j=2,nobs
        irec=iskrec(j)
        do i=j-1,1,-1
          if(jday(irec) .gt. jday(iskrec(i)) .or.
     >       (jday(irec) .eq. jday(iskrec(i)) .and.
     >       cskobs(irec)(1:10) .gt. cskobs(iskrec(i)))) goto 10
          iskrec(i+1)=iskrec(i)
        end do
        i=0
10      iskrec(i+1)=irec
      enddo

C  2. Generate scan names
      call sktime(lskobs(1,iskrec(1)),itim1)

      iptr=iskrec(1)
      call sktime(lskobs(1,iptr),itim1)
      scan_name(iptr)=ctim1(3:5)//"-"//ctim1(6:9)
      ndup=0
      iptr_old=iptr

      do i=2,nobs
        iptr=iskrec(i)
        call sktime(lskobs(1,iptr),itim1)
        scan_name(iptr)=ctim1(3:5)//"-"//ctim1(6:9)
        if(scan_name(iptr)(1:8).eq.scan_name(iptr_old)(1:8))then
          if(ndup .eq. 0) then
            ndup=ndup+1
            scan_name(iptr_old)(9:9)=lextra(ndup:ndup)
          endif
          ndup=ndup+1
          scan_name(iptr)(9:9)=lextra(ndup:ndup)
        else
          ndup=0
        endif
        iptr_old=iptr
      end do

      return
      end
