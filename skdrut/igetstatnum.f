      integer function igetstatnum(c1)
! Check 1 character station ID, and return station #, or 0 if not found.
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'

      character*1 c1    !one character station name

      integer iwhere_in_string_list

      igetstatnum=iwhere_in_string_list(cstcod,nstatn,c1)
      return
      end
