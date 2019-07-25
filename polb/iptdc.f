      integer function iptdc(decin,lbuf,icnext)
C
      double precision dec,dec1,dec2,decin
      include '../include/dpi.i'
C
C DECLINATION
C
      dec=abs(decin)*rad2deg*3600.0d0
      ih=int(dec/3600.0d0)
      dec1=dec-3600.0d0*float(ih)
      im=int(dec1/60.0d0)
      dec2=dec1-60.0d0*float(im)
      is=int(dec2+0.5d0)
      if (is.lt.0) is=0
      if (is.gt.59) is=59
C
      iptdc=ichmv_ch(lbuf,icnext,'+')
      if (decin.lt.0.0) iptdc=ichmv_ch(lbuf,icnext,'-')
      iptdc=iptdc+ib2as(ih,lbuf,iptdc,o'40000'+o'400'*2+2)
      iptdc=iptdc+ib2as(im,lbuf,iptdc,o'40000'+o'400'*2+2)
      iptdc=iptdc+ib2as(is,lbuf,iptdc,o'40000'+o'400'*2+2)

      return
      end
