      logical function kvalid_rack(crack)
      include '../skdrincl/valid_hardware.ftni'

! Passed.
      character*(*) crack     !rack

! Check for crack being a valid rack type. If not kvalid=.false.
! This does two checks:
!  1. Normal. If it finds, returns w/o doing anythying and kvalid=.true.
!  2. Capitalized. If it finds capitalized version of crack, then returns
!     normal version.
! History
!  2006Nov30 JMGIpson. First version.
!  2013Sep25 JMGipson. Modeled on check_rack_type. But bug fixed and made funciton. 

! functions
      integer iwhere_in_string_list
! local
      integer i
      character*8 cracktmp

      kvalid_rack=.true.
      i=iwhere_in_string_list(crack_type, max_rack_type,crack)
      if(i .ne. 0) return           !valid rack type.

! Didn't find. Capitalize and try again.
      cracktmp=crack
      call capitalize(cracktmp)
      i=iwhere_in_string_list(crack_type_cap,max_rack_type,cracktmp)
      if(i .ne. 0) then
         crack=crack_type(iwhere)         
      else
         kvalid_rack=.false.
      endif
      return
      end
