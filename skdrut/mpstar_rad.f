      subroutine mpstar_rad(tjd,rarad,decrad)
! do precession when args are input in radians
      implicit none
      include "../skdrincl/constants.ftni"
      double precision rarad,decrad

      double precision rah,decd,radh,decdd,tjd ! for APSTAR

      rah = RARAD*Rad2Ha
      decd = DECRAD*Rad2Deg
      call mpstar(tjd,3,rah,decd,radh,decdd)
      RARAD=radh*hA2rad
      DECRAD=decdd*deg2rad
      return
      end

