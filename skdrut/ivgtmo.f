      integer FUNCTION ivgtmo(cdef,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
C     CHECK THROUGH LIST OF mode def names FOR A MATCH WITH cdef.
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
      character*128 cdef
      integer fvex_len,i1,i2,ikey,i
      logical kmatch
      IKEY=0
      ivgtmo = 0
      IF (NCODES.LE.0) RETURN
      kmatch=.false.
      i=1
      DO while (i.le.NCODES.and..not.kmatch)
        i1=fvex_len(modedefnames(i))
        i2=fvex_len(cdef)
        kmatch= (modedefnames(I)(1:i1).eq.cdef(1:i2))
        i=i+1
      enddo
      i=i-1
      if (i.gt.ncodes) RETURN
      IKEY=I
      ivgtmo = I
      RETURN
      END
