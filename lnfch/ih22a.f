      function ih22a(ibyte) 
C 
C     ROUTINE TO CONVERT LOWER 8 BITS OF IBYTE TO A PRINTABLE A2 HEX. 
C 
c     integer*2 itab(8)
c     data itab /'01','23','45','67','89','ab','cd','ef'/
      character*1 tab(16)
      data tab / '0','1','2','3','4','5','6','7',
     &            '8','9','a','b','c','d','e','f'/
C 
c     ih22a=jchar(itab,iand(ibyte,o'360')/o'20'+1)*o'400'+
c    .      jchar(itab,iand(ibyte,o'17')+1) 
c     
c     call pchar(ih22a,1,jchar(itab,iand(ibyte,o'360')/o'20'+1))
c     call pchar(ih22a,2,jchar(itab,iand(ibyte,o'17')+1))
c
      call pchar(ih22a,1,ichar(tab(and(ibyte,o'360')/o'20'+1)))
      call pchar(ih22a,2,ichar(tab(and(ibyte,o'17')+1)))

      return
      end 
