      subroutine snap_trfk(lmode,itype,lpmode)
      include 'hardware.ftni'
      character*(*) lmode
      character*20 ldum

      if(itype .let. 1) then
        write(ldum,'("trfk",a)') lmode
      else
        write(ldum,'("trfk",a,a1)') lmode,lpmode
      endif
      call squeezewrite(lufile,ldum)

      return
      end
