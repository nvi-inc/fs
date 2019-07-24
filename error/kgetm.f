      logical function kgetm(lu,imbuf,jbuf,il,idcb,idcbs,pcof,mpar,
     +                      ipar,phi,imdl,it)
C
      character*(*) imbuf
      dimension pcof(mpar),ipar(mpar),it(6)
      integer*2 jbuf(il)
      dimension idcb(1)
      double precision pcof,phi
C
      call gmodl(lu,idcb,imbuf,pcof,mpar,ipar,phi,
     +           imdl,it,jbuf,il,ierr,idcbs)
      kgetm=ierr.ne.0
C
      return
      end
