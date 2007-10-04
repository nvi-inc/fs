      subroutine check_rack_type(crack)
      include '../skdrincl/valid_hardware.ftni'

! Passed.
      character*(*) crack     !rack

! Check for crack being a valid rack type. If not set to "unknown".
! This does two checks:
!  1. Normal. If it finds, returns w/o doing anythying.
!  2. Capitalized. If it finds capitalized version of crack, then returns
!     normal version.
! History
!  2006Nov30 JMGIpson. First version.

! functions
      integer iwhere_in_string_list
! local
      integer iwhere
      character*8 cracktmp

      iwhere=iwhere_in_string_list(crack_type, max_rack_type,crack)
      if(iwhere .eq. 0) return           !valid rack type.

! Didn't find. Capitalize and try again.
      cracktmp=crack
      call capitalize(cracktmp)
      iwhere=
     >   iwhere_in_string_list(crack_type_cap,max_rack_type,cracktmp)
      if(iwhere .eq. 0) then
        write(*,*) "Check_rack_type: Invalid rack ",crack,
     >     " setting to unknown!"
        crack="unknown"
      else
        crack=crack_type(iwhere)
      endif
      return
      end
