      logical function kinit(lu,iibuf,iobuf,iapp,imbuf,lst)
C
      character*(*) iibuf,iobuf,imbuf
      character append
      character*2 luout
      character*64 imdbuf
      character*40 cbuf
C
      data imdbuf/'/usr2/control/parpo.ctl'/
C
      kinit=.true.
      lu=6
C
      call rcpar(1,iibuf)
      if (iibuf.eq.' ') goto 8000
C
      call rcpar(2,iobuf)
      if (iobuf.eq.' ') goto 8100
C
      call rcpar(3,append)
      call char2low(append)
      if (append.eq.' ') then
        iapp=-1
      else if (append.eq.'o') then
        iapp=0
      else if (append.eq.'a') then
        iapp=1
      else
        call po_put_c('third argument must be a or o.')
        goto 8100
      endif
C
      call rcpar(4,imbuf)
      if (imbuf.eq.' ') imbuf = imdbuf
C
C GET LIST LU IF ANY
C
      call rcpar(5,luout)
      if (luout.eq.' ') then
        lst=0
      else
        lst = ichar(luout) - 48
        if (lst.le.0) then
          cbuf= ' not an lu: ' // luout
          call po_put_c(cbuf)
          goto 8100
        endif
      endif
C
7000  continue
      kinit=.false.
      go to 10000
C
8000  continue
      call po_put_c('xtrac: extract pointing data from log')
      call po_put_c('usage: xtrac input output [o/a[ pfile[ lu]]]')
      call po_put_c('where: input  is the input file name')
      call po_put_c('       output is output file name')
      call po_put_c('       o/a    is the overwrite/append flag for out
     .put')
      call po_put_c('       pfile  is the parameter file [/control/parp
     .o.ctl]')
      call po_put_c('       lu     is the listing')
      go to 10000
C
8100  continue
      call po_put_c(' for help: xtrac')
C
10000 continue
C
      return
      end
