      integer function isecdif(idayr1,ihr1,min1,isc1,
     .                         idayr2,ihr2,min2,isc2)

C  ISECDIF computes the number of seconds different between time
C  1 and time 2, in the sense of (time1 minus time2).

C 960810 nrv New utility for snap.f 
C 990326 nrv Allow for year rollover by checking whether nd<0.
C 990716 nrv Implement the change!

C Input:
      integer idayr1,ihr1,min1,isc1,idayr2,ihr2,min2,isc2
C Local:
C     integer nd,nh,nm,ns,nsdif
      integer idt,idd
      double precision t1,t2

      t1 = ihr1*3600.d0 + min1*60.d0 + isc1*1.d0
      t2 = ihr2*3600.d0 + min2*60.d0 + isc2*1.d0
      idd = idayr1-idayr2
      idt = t1-t2 + idd*3600.d0*24.0
      isecdif = idt
      
C     nd = idayr1 - idayr2
C     nh = ihr1 - ihr2
C     nm = min1 - min2
C     ns = isc1 - isc2
C     if (ns.lt.0) then
C       ns = ns + 60
C       nm = nm - 1
C     endif
C     if (nm.lt.0) then
C       nm = nm + 60
C       nh = nh - 1
C     endif
C     if (nh.lt.0) then
C       nh = nh + 24
C       nd = nd - 1
C     endif
C     if (nd.lt.0) then
C       nd = nd + 365
C     endif
C     nsdif = nd*86400 + nh*3600 + nm*60 + ns

C     isecdif = nsdif
     
      return
      end
