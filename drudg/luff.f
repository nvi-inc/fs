      subroutine luff(luprt)
C  Write form feed on printer
C  Different versions needed for UX and PC.
C  nrv 910705

C For PC:
C      write(luprt,'("1")')
C
C For UX:
       write(luprt,'(A)') char(12)

      return
      end

