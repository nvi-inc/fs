      program labck
C 
      integer*2 labt(4),lchk(2),labta(4),labtb(4) ,ihash,icode
C 
      lu = 6
      lui = 5
C 
200   write(lu,9901)
9901  format(1x,"enter tape number (:: to quit) ")
      read(lui,9902) labt
9902  format(4a2) 
      if (ichcm_ch(labt,1,'::').eq.0) goto 999 
      write(lu,9905)
9905  format(1x,"enter tape number again to double check (:: to quit) ")
      read(lui,9902) labta 
      if (ichcm_ch(labta,1,'::').eq.0) goto 999 
      write(lu,9906)
9906  format(1x,"enter tape number once more, just to be sure ", 
     .   " (:: to quit) ") 
      read(lui,9902)labtb
      if (ichcm_ch(labtb,1,'::').eq.0) goto 999 
C 
C     Generate check label.  Change any "O" to "0" in tape number first.
C     Check for exactly 8 characters in tape number.
C 
      do 322 i=1,8
        ic = jchar(labt,i)
        if (ic.ne.o'40') goto 321 
C                            no blanks allowed
        write(lu,9904)
9904    format(1x,"tape label must be exactly 8 characters, no blanks all
     .owed.  try again.") 
        goto 200
321     if (ic.eq.o'117') call ichmv(labt,i,o'60',2,1)
C                            "O"                     "0"
        if(jchar(labta,i).eq.ic.and.jchar(labtb,i).eq.ic) goto 322
          write(lu,9907)
9907      format(1x,"tape numbers disagree. try again.") 
          goto 200
322     continue
      call upper(labt,1,8)
C 
      icode = ihash(labt,1,8) 
      lchk(1) = ih22a(jchar(icode,2)) 
      lchk(2) = ih22a(jchar(icode,1))
      call upper(lchk,1,4)
C 
C     Now LCHK contains the four hex characters in the correct
C     check label.
C 
      write(lu,9903) lchk 
9903  format(1x,"check label is "2a2)  
999   continue    
C
      end 
