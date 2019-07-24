      subroutine pas2mic(ihead,ipass,micron,ip)
      integer ihead,ipass,ip(5)
      real*4 micron
C
C  PAS2MIC: convert pass number to micron position
C
      include '../include/fscom.i'
C
C  INPUT:
C     IHEAD: head to convert pass to microns: 1 or 2
C     IPASS: pass to look up position of: positive integer less than
C            or equal to maximum defined pass number
C
C  OUTPUT:
C     MICRON: determined position
C     IP: Field System return parameters
C     IP(3) = 0 if no error
C           = -403 if pass number is undefined
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  gag  920721  Added code to check for Mark IV style passes.
C
      if (ipass.gt.100) then
        itens = MOD(ipass,100)
        ihunds = ipass/100
        if (itapof4(itens,ihunds).gt.-13000) then
          micron=itapof4(itens,ihunds)
        else
          ip(3)=-403
          call char2hol('q@',ip(4),1,2)
          return
        endif
      else if (itapof(ipass).gt.-13000) then
        micron=itapof(ipass)
      else
        ip(3)=-403
        call char2hol('q@',ip(4),1,2)
        return
      endif
C
      return
      end
