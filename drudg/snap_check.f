      subroutine snap_check(BitDens,idirp)
! passed
      include 'hardware.ftni'
      double precision BitDens
      integer idirp

! local
      character ldir
      character*3 ltmp
      integer ntmp
      character lpost

      if(idirp .eq. 1) then
         ldir="f"
      else
         ldir="r"
      endif

      if(bitdens .lt. 40000.0) then
        ntmp=3
        ltmp="135"
      else
        ntmp=2
        ltmp="80"
      endif

      if(krec_append) then
        lpost=crec(irec)
      else
        lpost=" "
      endif
      write(lufile,'("check",a,a1,a1)') ltmp(1:ntmp),ldir,lpost

      return
      end
