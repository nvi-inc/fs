      subroutine iadt(it,idt,ires)!c#870407:13:00    hp add time#

      dimension it(1),itm(5)
      data itm/100,60,60,24,365/
C
C   GET INITIAL INCREMENT
C
      iix=idt
C
C   INITIALIZE ILP
C   GET # DAYS/YEAR
C
      itm(5)=365
      if (mod(it(6),4).eq.0) itm(5)=366
C
C   SET UP LOOP
C
      do 20000 i=ires,5
C
C   INCREMENT THIS VALUE
C 
        it(i)=it(i)+iix 
C 
C   HAS THIS UNIT OVERFLOWED
C 
        if (it(i).lt.itm(i)) goto 60000
C 
C   GET REMAINDER FOR THIS UNIT 
C 
        itx=mod(it(i),itm(i)) 
C 
C   GET THE CARRY TO HIGHER UNIT
C 
        iix=it(i)/itm(i)
C 
C   SET CURRENT UNITS TO REMAINDER
C 
        it(i)=itx 
C 
20000   continue
C 
C   INCREMENT YEAR (ASSUME NO BIGGER CHANGE)
C 
      it(6)=it(6)+1 
C 
60000 continue
C 
      return
      end 
