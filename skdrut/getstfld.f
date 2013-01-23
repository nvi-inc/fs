      subroutine getstfld(stdef,stmt,prim,ivexnum,cout,nfields,
     .lu,ierr)

C     Get all the fields associated with one statement for
C     a station.

      include ../skdrincl/skparm.ftni

C History:
C 960516 nrv New.

C Input:
      integer lu ! for error messages
      character*(*) stdef
      character*(*) stmt ! statement to get
      character*(*) prim ! primitive section name
      integer ivexnum    ! vex file number

C Output:
      integer nfields
      character*(*) cout(max_fld)
      integer ierr

C Local:
      integer i,i1,i2,i3
      integer trimlen,fget_station_lowl,vex_field ! functions


C  1. Get the low level statement.

      ierr = fget_station_lowl(nfields,stdef,stmt,prim,ivexnum)

      i1=trimlen(stmt)
      i2=trimlen(prim)
      i3=trimlen(stdef)

      if (ierr.ne.0) then
        write(lu,9901) ierr,stmt(1:i1),prim(1:i2),stdef(1:i3)
9901    format('GETSTFLD01 - VEX error ',i6,' in ',a,' ',a,
     .  ' for station ',a)
        return
      endif

C  2. Now get the fields.

      do i=1,nfields
        ierr = vex_field(i,cout(i))
        if (ierr.ne.0) then
          write(lu,9902) ierr,i,stmt(1:i1),prim(1:i2),stdef(1:i3)
9902      format('GETSTFLD02 - Error ',i6,' getting field ',i5,
     .    ' in ',a,' ',a,' for station ',a)
          return
        endif
      enddo

      return
      end
