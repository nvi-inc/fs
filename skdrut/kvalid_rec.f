      logical function kvalid_rec(crec)
      implicit none 
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
!  2013Sep25 JMGipson. First version modeled on check_rec_type

! functions
      integer iwhere_in_string_list
! local
      integer iwhere
      character*8 crectmp

      kvalid_rec=.true. 
      iwhere=iwhere_in_string_list(crec_type, max_rec_type,crec)
      if(iwhere .eq. 0) return           !valid rec type.

! Didn't find. Capitalize and try again.
      crectmp=crec
      call capitalize(crectmp)
      iwhere= iwhere_in_string_list(crec_type_cap,max_rec_type,crectmp)
      if(iwhere .ne. 0) then
        crec=crec_type(iwhere)       
      else
        kvalid_rec=.false.
      endif
      return
      end
