      subroutine write_drudg_version_line(lu_out)
      implicit none 
      integer lu_out
      include 'drver_com.ftni'
       character*2 cprfx
! 2018Jul20 First version

      cprfx='" '
    
      write(lu_out,
     > "(a,'drudg version ',a9,' compiled under FS ',i2,2('.',i2.2),$)")
     >    cprfx,cversion,iVerMajor_FS,iverMinor_FS,iverPatch_FS

      if(crel_FS .eq. " ") then
        write(lu_out, '(a)') " "
      else 
        write(lu_out,'(a)') "-"//Crel_FS
       endif
       return
       end
