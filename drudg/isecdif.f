      integer function isecdif(idayr1,ihr1,min1,isc1,
     .                         idayr2,ihr2,min2,isc2)

C  ISECDIF computes the number of seconds different between time
C  1 and time 2, in the sense of (time1 minus time2).

C 960810 nrv New utility for snap.f 

C Input:
      integer idayr1,ihr1,min1,isc1,idayr2,ihr2,min2,isc2
C Local:
      integer nd,nh,nm,ns,nsdif

      nd = idayr1 - idayr2
      nh = ihr1 - ihr2
      nm = min1 - min2
      ns = isc1 - isc2
      if (ns.lt.0) then
        ns = ns + 60
        nm = nm - 1
      endif
      if (nm.lt.0) then
        nm = nm + 60
        nh = nh - 1
      endif
      if (nh.lt.0) then
        nh = nh + 24
        nd = nd - 1
      endif
      nsdif = nd*86400 + nh*3600 + nm*60 + ns

      isecdif = nsdif
     
      return
      end
