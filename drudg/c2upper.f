      subroutine c2upper(cbuf_in,cbuf_out)

C Convert a character string to upper case.

C 960201 nrv New.

      character*(*) cbuf_in
      character*(*) cbuf_out

C Local
      integer iin,iout
      character*1 c

      iin=len(cbuf_in)
      iout=len(cbuf_out)
      do i=1,iin 
        c=cbuf_in(i:i)
        if ((c.ge.'a').and.(c.le.'z')) then
           cbuf_out(i:i) = char(ichar(c) - (ichar('a') - ichar('A')))
        else
           cbuf_out(i:i) = c
        end if
      enddo
C     if (iiout.gt.iin) then
C       do i=iin+1,iiout
C         cbuf_out(i:i)=' '
C       enddo
C     endif

      return
      end

