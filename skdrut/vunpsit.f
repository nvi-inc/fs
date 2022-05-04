*
* Copyright (c) 2020-2021 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      SUBROUTINE vunpsit(stdef,ivexnum,iret,ierr,lu,
     .cidpos,cNAPOS,POSXYZ,POSLAT,POSLON,cOCCUP,naz,nel,azh,elh)
      implicit none  !2020Jun15 JMGipson automatically inserted.
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
! 2006Nov08 JMGipson. Fixed problem with horizon masks. (nhz was off by 1.)
!           Got rid of ASCII
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
      character*2 cidpos ! positon ID, 2 characters
      character*8 cNAPOS ! name of the site position
      character*8 coCCUP ! occupation code
      double precision POSXYZ(3) ! site coordinates, meters
      double precision poslat,poslon !omputer lat, lon
      integer naz,nel                  !number of az points, number of el points in mask 
      real azh(max_hor),elh(max_hor)
      character*2 lazel(2)                !Either "az" or "el"
      integer iazel                    !counter over azel 
      
! functions
      integer fget_station_lowl,fvex_field,fvex_double
      integer ptr_ch,fvex_units,fvex_len
C  LOCAL:
      character*128 cout,cunit,cunit_save
      double precision d
      integer i,nch
      data lazel/"az","el"/
C
C  INITIALIZED:
C
C
C  First initialize everything in case we have to leave early.

      posxyz(1) = 0.d0
      posxyz(2) = 0.d0
      posxyz(3) = 0.d0
  
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
        cnapos=cout(1:NCH)
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
        CIDPOS=cout(1:nch)
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
          write(lu,
     >  '("VUNPSIT05 - Error converting site position ","field ",i2)') i
        else
          posxyz(i) = d
        endif
      enddo ! x,y,z

C     Now compute derived coordinates

      if (ierr.gt.0) then
         call xyz2latlon(posxyz,poslat,poslon)
      endif

C  4. Occupation code

      coccup=" "
      ierr=4
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
          cOCCUP=cout(1:NCH)
        endif
      endif

C  5. AZ fields Horizon map
!  Read in Az, El horizon map. 
      
      do iazel=1,2
! Initialize       
        if(iazel .eq. 1) then       
          naz=0
          ierr=5
        else
          nel=0
          ierr=6 
        endif 
        iret = fget_station_lowl(ptr_ch(stdef),
     >           ptr_ch('horizon_map_'//lazel(iazel)//char(0)),
     >           ptr_ch('SITE'//char(0)),ivexnum)         
! Now read in the values 
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
              write(lu,'("VUNPSIT08 - Error in ",a2, " map field ",i3)') 
     >         lazel(iazel), i
            else
              if(iazel .eq. 1) then 
                azh(i)=d
              else
                elh(i)=d
              endif 
            endif
            i=i+1
            iret = fvex_field(i,ptr_ch(cout),len(cout))
          enddo ! get az fields
          if (i.gt.max_hor) then
            ierr=-9
            write(lu,"(a,a2,a,i2)") "VUNPSIT09 - Too many horizon ",
     >                lazel(iazel)," values.   max is ", max_hor
            i = max_hor
          else
            i=i-1        
            ierr=0 
          endif
          if(iazel .eq.1) then
            naz=i
          else
            nel=i
          endif
        endif
      end do   
      iret=0 
   
      if(nel+1 .lt. naz) then
        write(lu,'("VUNPSIT10 for station ", a)') stdef 
        write(lu,'(" Too few horizon el values  ", i2)') nel
        write(lu,'(" Must have az or az-1 ",2i3)') naz,naz-1     
      endif          
    
      if (ierr.gt.0) ierr=0
      return
      end
