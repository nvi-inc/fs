      subroutine gfields
c
      character*129 buffer,units
      integer ptr_ch,fvex_len,fvex_field,fvex_units

      do i=1,9
      ierr=fvex_field(i,ptr_ch(buffer),len(buffer))
      write(6,*) "i=",i," ierr from fvex_field=",ierr
      if(ierr.eq.-6) return

      if(fvex_len(buffer).gt.0)
     &write(6,*) "buffer='",buffer(1:fvex_len(buffer)),
     & "' len=",fvex_len(buffer)

      ierr=fvex_units(ptr_ch(units),len(units))
      write(6,*) "i=",i," ierr from fvex_units=",ierr

      if(fvex_len(units).gt.0) then
         write(6,*) "units='",units(1:fvex_len(units)),
     &        "' len=",fvex_len(units)
         ierr=fvex_double(ptr_ch(buffer),ptr_ch(units),double)
         write(6,*) " ierr from fvex_double=",ierr," doube=",double
      endif

      enddo
      end
