      integer function isecdif(idayr1,ihr1,min1,isc1,
     .                         idayr2,ihr2,min2,isc2)

C  ISECDIF computes the number of seconds different between time
C  1 and time 2, in the sense of (time1 minus time2).
      include '../skdrincl/skparm.ftni'

C 960810 nrv New utility for snap.f 
C 990326 nrv Allow for year rollover by checking whether nd<0.
C 990716 nrv Implement the change!
C 990924 nrv Utility for sked's vscout.f. Add skparm.ftni and
C            make t1,t2 double.

C Input:
      integer idayr1,ihr1,min1,isc1,idayr2,ihr2,min2,isc2
C Local:
      integer idt,idd
      double precision t1,t2

      t1 = ihr1*3600.d0 + min1*60.d0 + isc1*1.d0
      t2 = ihr2*3600.d0 + min2*60.d0 + isc2*1.d0
      idd = idayr1-idayr2
      idt = t1-t2 + idd*3600.d0*24.0
      isecdif = idt
      
      return
      end
