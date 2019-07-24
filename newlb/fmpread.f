      integer function fmpread(dcb,error,buffer,max)

      integer dcb(2),error,buffer(1),max
      integer ilen,fmpreadstr
      character*128 cbuf

      error = 0
      cbuf=' '
      ilen = fmpreadstr(dcb,error,cbuf)
      if (error.ne.0) then
        fmpread=error
        return
      end if

      if (ilen.eq.-1) then
        fmpread = ilen
        return
      endif
      if (ilen.lt.max) then
        call char2hol(cbuf,buffer,1,ilen)
        fmpread = ilen
      else
        call char2hol(cbuf,buffer,1,max)
        fmpread = max
      endif

      return
      end
