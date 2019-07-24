      subroutine get_class(ibuf,ilen,ip,nchar)

      implicit none
      integer*2 ibuf(1)
      integer ilen,nchar,ip(1)
C
C  get_class: retreive class record
C
C  input:
C     ILEN: size of IBUF, +WORDS or -BYTES
C     IP: field system parameters
C         IP(1): class #
C         IP(2): number of class records available on entry
C
C  output:
C     IBUF: buffer containing at most ILEN +WORDS or -BYTES
C     NCHAR: number of characters (bytes) actually returned in IBUF
C     IP: field system parameters
C        IP(1): unmodifed
C        IP(2): number of class records remaining on return
C
      integer get_buf,idum
      integer ireg(2)
      real*4 reg,exec
      equivalence (ireg(1),reg)
C
      if(ip(2).le.0) then
        ip(3)=-402
        call char2hol('q@',ip(4),1,2)
        return
      endif
C
      ireg(2)=get_buf(ip(1),ibuf,ilen,idum,idum)
      nchar=-ilen
      if(ilen.gt.0) nchar=2*ilen
      nchar = min0(ireg(2),nchar)
      ip(2)=ip(2)-1
C
      return
      end
