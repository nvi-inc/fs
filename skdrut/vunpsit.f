      SUBROUTINE vunpsit(stdef,ivexnum,iret,ierr,lu,
     .lidpos,LNAPOS,POSXYZ,POSLAT,POSLON,LOCCUP,
     .nhz,azh,elh)
C
C     VUNPSIT gets the site information for station
C     STDEF and converts it.
C     All statements are gotten and checked before returning.
C     Any invalid values are not loaded into the returned
C     parameters.
C     Only generic error messages are written. The calling
C     routine should list the station name for clarity.
C
      include '../skdrincl/skparm.ftni'
C
C  History:
C 960517 nrv New.
C 960521 nrv Revised.
C 960605 nrv Allow 1-character site IDs, e.g. VLA=Y
C 970123 nrv Move initialization to front.
C
C  INPUT:
      character*128 stdef ! station def to get
      integer ivexnum ! vex file ref
      integer lu ! unit for writing error messages
C
C  OUTPUT:
      integer iret ! error return from vex routines
      integer ierr ! error return from this routine, >0 is section
C          where error occurred, <0 is invalid value
      integer*2 lidpos ! positon ID, 2 characters
      integer*2 LNAPOS(4) ! name of the site position
      double precision POSXYZ(3) ! site coordinates, meters
      integer*2 LOCCUP(4) ! occupation code
      real poslat,poslon !omputer lat, lon
      integer nhz
      real azh(max_hor),elh(max_hor)

C  LOCAL:
      character*128 cout,cunit,cunit_save
      double precision d
      integer i,nch,idumy
      integer fget_station_lowl,fvex_field,fvex_double,
     .ptr_ch,fvex_units,fvex_len,ichmv_ch ! function
C
C  INITIALIZED:
      double precision ERAD,EFLAT
C               - compiled-in values of earth rad and flattening
      DATA ERAD/0.6378145D07/
      DATA EFLAT/0.3352891869D-2/
C
C
C  First initialize everything in case we have to leave early.

      CALL IFILL(LNAPOS,1,8,oblank)
      CALL IFILL(lidpos,1,2,oblank)
      posxyz(1) = 0.d0
      posxyz(2) = 0.d0
      posxyz(3) = 0.d0
      CALL IFILL(LOCCUP,1,8,oblank)
      nhz=0

C  1. The site name.
C
      ierr=1
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('site_name'//char(0)),
     .ptr_ch('SITE'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      if (iret.ne.0) return
      NCH = fvex_len(cout)
      IF  (NCH.GT.8.or.NCH.le.0) THEN  !
        write(lu,'("VUNPSIT01 - Site name too long")')
        ierr=-1
      else
        IDUMY = ICHMV_ch(LNAPOS,1,cout(1:NCH))
      endif
C
C  2. Site ID. Standard 2-letter code.

      ierr=2
      iret = fget_station_lowl(ptr_ch(stdef),ptr_ch('site_ID'//char(0)),
     .ptr_ch('SITE'//char(0)),ivexnum)
      if (iret.ne.0) return
      iret = fvex_field(1,ptr_ch(cout),len(cout))
      if (iret.ne.0) return
      NCH = fvex_len(cout)
      IF  (NCH.gt.2) THEN 
        write(lu,'("VUNPSIT02 - Site code must be 2 characters")')
        ierr=-2
      else
        IDUMY = ICHMV_ch(LIDPOS,1,cout(1:nch))
      endif

C  3. Site position

      ierr=3
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('site_position'//char(0)),
     .ptr_ch('SITE'//char(0)),ivexnum)
      if (iret.ne.0) return
      do i=1,3 ! x,y,z
        iret = fvex_field(i,ptr_ch(cout),len(cout)) ! get x,y,z component
        if (iret.ne.0) return
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
        if (iret.ne.0) then
          ierr=-5
          write(lu,'("VUNPSIT05 - Error converting site position ",
     .    "field ",i2)') i
        else
          posxyz(i) = d
        endif
      enddo ! x,y,z

C     Now compute derived coordinates

      if (ierr.gt.0) then 
        POSLON = (-DATAN2(POSXYZ(2),POSXYZ(1)))*180.0/PI
        IF (POSLON.LT.0.D0) POSLON=POSLON+360.D0
C                   West longitude = ATAN(y/x)
        POSLAT = (DATAN2(POSXYZ(3)*ERAD**2,
     .    DSQRT((POSXYZ(1)**2+POSXYZ(2)**2)) *
     .    (ERAD**2*(1.D0-EFLAT)**2))) * 180.0/PI
C                   Geocentric latitude = ATAN(z/sqrt(x^2+y^2))
C                   Geodetic latitude includes earth radius and flattening
      endif

C  4. Occupation code

      ierr=4
      CALL IFILL(LOCCUP,1,8,oblank)
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('occupation_code'//char(0)),
     .ptr_ch('SITE'//char(0)),ivexnum)
      if (iret.eq.0) then ! got one
        iret = fvex_field(1,ptr_ch(cout),len(cout))
        if (iret.ne.0) return
        NCH = fvex_len(cout)
        IF  (NCH.GT.8.or.NCH.le.0) THEN  !
          write(lu,'("VUNPSIT06 - Occupation code too long")')
          ierr=-6
        else
          IDUMY = ICHMV_ch(LOCCUP,1,cout(1:NCH))
        endif
      endif

C  5. AZ fields Horizon map

      ierr=5
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('horizon_map_az'//char(0)),
     .ptr_ch('SITE'//char(0)),ivexnum)
      nhz=0
      if (iret.eq.0) then
        i=1
        iret = fvex_field(i,ptr_ch(cout),len(cout))
        do while (i.le.max_hor.and.iret.eq.0) ! get az fields
          if (iret.ne.0) return
          iret = fvex_units(ptr_ch(cunit),len(cunit))
          if (iret.ne.0) return
          if (fvex_len(cunit).eq.0) then ! use previous units
            cunit=cunit_save
          endif
          cunit_save=cunit
          iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
          if (iret.ne.0.or.d.lt.0.d0) then
            ierr=-8
            write(lu,'("VUNPSIT08 - Error in az map field ",i3)') i
          else
            azh(i)=d
          endif
          i=i+1
          iret = fvex_field(i,ptr_ch(cout),len(cout))
        enddo ! get az fields
        if (i.gt.max_hor) then
          ierr=-9
          write(lu,'("VUNPSIT09 - Too many horizon azs, max is ",
     .    i2)') max_hor
          nhz = max_hor
        else
          nhz = i
        endif
      else
        iret=0
        ierr=0
        return ! no az, no el
      endif

C  6. EL fields Horizon map

      ierr=6
      iret = fget_station_lowl(ptr_ch(stdef),
     .ptr_ch('horizon_map_el'//char(0)),
     .ptr_ch('SITE'//char(0)),ivexnum)
      if (iret.ne.0) return
      i=1
      iret = fvex_field(i,ptr_ch(cout),len(cout))
      do while (i.le.max_hor.and.iret.eq.0) ! get el fields
        if (iret.ne.0) return
        iret = fvex_units(ptr_ch(cunit),len(cunit))
        if (iret.ne.0) return
          if (fvex_len(cunit).eq.0) then ! use previous units
            cunit=cunit_save
          endif
          cunit_save=cunit
        iret = fvex_double(ptr_ch(cout),ptr_ch(cunit),d)
        if (iret.ne.0.or.d.lt.0.d0) then
          ierr=-8
          write(lu,'("VUNPSIT08 - Error in el map field ",i3)') i
        else
          elh(i)=d
        endif
        i=i+1
        iret = fvex_field(i,ptr_ch(cout),len(cout))
      enddo ! get el fields
      iret=0
      if (i.gt.max_hor) then
        ierr=-9
        write(lu,'("VUNPSIT09 - Too many horizon els, max is ",
     .  i2)') max_hor
      endif

      if (ierr.gt.0) ierr=0
      return
      end
