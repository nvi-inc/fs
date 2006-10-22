      double precision Function ctime2dmjd(ctim_skd)
! convert a sked character*11 string into double precision time.
! passed
      implicit none
      character*11 ctim_skd
! function
      integer julda
      double precision hms2seconds
! local
      integer iy_skd,idoy_skd,ih_skd,im_skd,is_skd

      read(ctim_skd,'(i2,i3,3i2)') iy_skd,idoy_skd,ih_skd,im_skd,is_skd
      if(iy_skd.gt.50) then
        iy_skd=iy_skd+1900
      else
        iy_skd=iy_skd+2000
      endif
!      write(*,*) iy_skd,idoy_skd,ih_skd,im_skd,is_skd
!      write(*,*) hms2seconds(ih_skd,im_skd,is_skd)

      CTime2dmjd=dble(JULDA(1,idoy_skd,iy_skd-1900))+
     >     hms2seconds(ih_skd,im_skd,is_skd)/86400.d0
!      write(*,*) Ctime2dmjd
      return
      end
