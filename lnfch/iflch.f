      function iflch(ibuf,ilen)

C     IFLCH - finds the last character in the buffer
C             by lopping off trailing blanks
C 
C 
C  INPUT: 
C 
      dimension ibuf(1) 
C     ILEN - length of IBUF in CHARACTERS 
C 
C 
C  OUTPUT:
C 
C     IFLCH - number of characters in IBUF
C 
C 
C  LOCAL: 
      character cjchar
C 
C     LTERM - termination character 
C 
C 
C  INITIALIZED: 
C 
C 
C  PROGRAMMER:  NRV 
C  LAST MODIFIED 800825 
C 
C 
C     1. Step backwards through the buffer, deleting any
C     blanks as we come to them.
C 
      nb = 0
      do 100 i=ilen,1,-1
        if (cjchar(ibuf,i).eq.' ') nb = nb + 1 
        if (cjchar(ibuf,i).ne.' ') goto 101
100     continue
101   iflch = ilen - nb 

      return
      end 
