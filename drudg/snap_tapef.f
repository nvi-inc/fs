      subroutine snap_tapef(lmode,lpmode)
      implicit none
      include 'hardware.ftni'
      character*(*) lmode,lpmode
      character*20 ldum
      character*1 lchar

      if(krec_append) then
        lchar=crec(irec)
      else
        lchar=" "
      endif
      write(ldum,'("tapef",a,a,a1)') lmode,lpmode,lchar
      call squeezewrite(lufile,ldum)

      end

