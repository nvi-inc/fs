      subroutine apstar_rad(tjd,ra50,dec50,ra,dec)
! convert from epoch 1950
      implicit none
      include "../skdrincl/constants.ftni"
      double precision ra50,dec50,ra,dec

      double precision rah,decd,radh,decdd,tjd ! for APSTAR


      rah = ra50*Rad2HA
      decd = dec50*rad2deg
      call apstar(tjd,3,rah,decd,0.d0,0.d0,0.d0,0.d0,radh,decdd)
      ra=radh*HA2Rad
      dec=decdd*deg2rad
      return
      end

