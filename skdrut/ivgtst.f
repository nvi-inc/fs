      integer FUNCTION ivgtst(cdef,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
C     CHECK THROUGH LIST OF station names FOR A MATCH WITH cdef.
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
      character*128 cdef
      integer fvex_len,i1,i2,ikey,i
      logical kmatch
      IKEY=0
      ivgtst = 0
      IF (NSTATN.LE.0) RETURN
      kmatch=.false.
      i=1
      DO while (i.le.NSTATN.and..not.kmatch)
        i1=fvex_len(stndefnames(i))
        i2=fvex_len(cdef)
        kmatch= (stndefnames(I)(1:i1).eq.cdef(1:i2))
        i=i+1
      enddo
      i=i-1
      if (i.gt.nstatn) RETURN
      IKEY=I
      ivgtst = I
      RETURN
      END
