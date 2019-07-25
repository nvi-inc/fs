      integer function iptra(rain,lbuf,icnext)
C
      double precision ra,ra1,ra2,ra3,rain
      include '../include/dpi.i'
C
C RA
C
      ra=rain*rad2sec*10.0d0
      ih=int(ra/36000.0d0)
      ra1=ra-36000.0d0*float(ih)
      im=int(ra1/600.0d0)
      ra2=ra1-600.0d0*float(im)
      is=int(ra2/10.d0)
      ra3=ra2-10.0d0*float(is)
      its=int(ra3+0.5d0)
      if (its.lt.0) its=0
      if (its.gt.9) its=9
C
      iptra=icnext+ib2as(ih,lbuf,icnext,o'40000'+o'400'*2+2)
      iptra=iptra+ib2as(im,lbuf,iptra,o'40000'+o'400'*2+2)
      iptra=iptra+ib2as(is,lbuf,iptra,o'40000'+o'400'*2+2)
      iptra=ichmv_ch(lbuf,iptra,'.')
      iptra=iptra+ib2as(its,lbuf,iptra,o'40000'+o'400'*1+1)

      return
      end
