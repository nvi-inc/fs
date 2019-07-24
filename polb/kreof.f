      logical function kreof(lut,ierr,len,irec,ipbuf)

      logical kfmp
      character*(*) ipbuf
C
      integer*2 lpeof(23),lred(16)
C
      data lpeof  /  44,2Hpr,2Hem,2Hat,2Hur,2He ,2Heo,2Hf ,2Hbe,2Hfo,
     /             2Hre,2H r,2Hea,2Hdi,2Hng,2H r,2Hec,2Hor,2Hd ,2Hxx,
     /             2Hxx,2H i,2Hn_/
C          premature eof before reading record xxxx in_
      data lred   /  30,2Hbe,2Hfo,2Hre,2H r,2Hea,2Hdi,2Hng,2H r,2Hec,
     /             2Hor,2Hd ,2Hxx,2Hxx,2H i,2Hn_/
C          before reading record xxxx in_

      kreof=.false.
      if (len.ge.0) goto 10
      ifc=37
      ifc=ifc+ib2as(irec,lpeof(2),ifc,o'100000'+4)
      ifc=ichmv(lpeof(2),ifc,4h in_ ,1,4)
      kreof=kfmp(lut,ierr,lpeof(2),ifc-1,ipbuf,0,1)
      return
C
10    continue
      if (ierr.eq.0) return
      ifc=23
      ifc=ib2as(irec,lred(2),ifc,o'100000'+4)
      ifc=ichmv(lred(2),ifc,4h in_ ,1,4)
      kreof=kfmp(lut,ierr,lred(2),ifc-1,ipbuf,0,1)
C
      return
      end
