      subroutine check_rec_type(crec)
      include '../skdrincl/valid_hardware.ftni'

! Passed.
      character*(*) crec     !rec
! Check for crec being a valid rec type. If not set to "unknown".
! This does two checks:
!  1. Normal. If it finds, returns w/o doing anythying.
!  2. Capitalized. If it finds capitalized version of crec, then returns
!     normal version.
! History
!  2006Nov30 JMGIpson. First version.

! functions
      integer iwhere_in_string_list
! local
      integer iwhere
      character*8 crectmp

!  Capitalize and try to find 
      crectmp=crec
      call capitalize(crectmp)
      iwhere= iwhere_in_string_list(crec_type_cap,max_rec_type,crectmp)
      if(iwhere .eq. 0) then
!        write(*,*) "Check_rec_type: Invalid recorder ",crec,
!     >     " setting to unknown!"
        crec="unknown"
      else
        crec=crec_type(iwhere)
      endif
      return
      end
