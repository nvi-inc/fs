*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      logical function kinit(lu,iibuf,iobuf,iapp,imbuf,lst)
C
      integer leng, ierrg
      integer*2 jbufg(100)
      logical kgot
      common/got/leng,ierrg,jbufg,kgot
C
      character*(*) iibuf,iobuf,imbuf
      character append
      character*2 luout
      character*64 imdbuf
      character*40 cbuf
C
      data imdbuf/'/usr2/control/mdlpo.ctl'/
C
      call rcpar(-1,'error')
C
      kgot=.false.   !! initialize kgot
      kinit=.true.
      lu=6
C
      iibuf=' '
      call rcpar(1,iibuf)
      if (iibuf.eq.' ') goto 8000
C
      iobuf=' '
      call rcpar(2,iobuf)
      if (iobuf.eq.' ') goto 8100
C
      append=' '
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
      imbuf=' '
      call rcpar(4,imbuf)
      if (imbuf.eq.' ') imbuf = imdbuf
C
C GET LIST LU IF ANY
C
      luout=' '
      call rcpar(5,luout)
      if (luout.eq.' ') then
        lst=0
      else
        lst = ichar(luout(1:1)) - 48 
        if (lst.le.0) then
          cbuf= ' not an lu: ' // luout
          call po_put_c(cbuf)
          goto 8100
        endif
      endif
C
      kinit=.false.
      go to 10000
C
8000  continue
      call po_put_c('error: fit pointing offsets to model')
      call po_put_c('usage: error input output [o/a[ model[,lu]]]')
      call po_put_c('where: input  is the input file name')
      call po_put_c('       output is output file name')
      call po_put_c('       o/a    is the overwrite/append flag for outp
     .ut')
      call po_put_c('       model  is the model file [/control/mdlpo.ctl
     .]')
      call po_put_c('       lu     is the listing lu')
      go to 10000
C
8100  continue
      call po_put_c(' for help: error')
      go to 10000
C
10000 continue
      return
      end
