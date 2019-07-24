      function ih22a(ibyte) 
C 
C     ROUTINE TO CONVERT LOWER 8 BITS OF IBYTE TO A PRINTABLE A2 HEX. 
C 
      integer*2 itab(8)
      data itab /'01','23','45','67','89','ab','cd','ef'/
C 
c     ih22a=jchar(itab,iand(ibyte,o'360')/o'20'+1)*o'400'+
c    .      jchar(itab,iand(ibyte,o'17')+1) 
      
      call pchar(ih22a,1,jchar(itab,iand(ibyte,o'360')/o'20'+1))
      call pchar(ih22a,2,jchar(itab,iand(ibyte,o'17')+1))

      return
      end 
