        real function gbfas(ibuf,istrt,iend)
C 
C           This routine will return an integer found starting at 
C    ISTRT.  The integeter will be terminated when this routine either
C    reaches IEND, or comes to the first non integer character after
C    finding an integer or sign.  The number found is returned in the 
C    A reg (IRGA) with the count in the B reg (IRGB).  The returned 
C    information should be studied in the write up which follows. 
C 
C 
C     INPUT PARAMETERS: 
C 
        dimension ibuf(1),ireg(2) 
C 
        logical knumf 
C 
C       IBUF    - the input buffer
C 
C       ISTRT   - the first character in IBUF to start with 
C 
C       IEND    - the last character to be used in IBUF 
C 
C 
C      OUTPUT PARAMETERS: 
C 
C 
C       GBFAS  -  with the EQUIVALENCE (GBFAS,IRGA,IREG(1)),(IRGB,IREG(2))
C 
C        IRGA   - the integer found starting at ISTRT and as given
C                 by the ISTAT part of IRGB 
C 
C        IRGB   =  ISTAT*o'400'+ICNT
C 
C             ICNT  -   the count of the charcters used in the return 
C                       of the rest of the information from this call 
C 
C             ISTAT -  0  normal return (i. e. IRGA ia valid and in the 
C                         range -32768 <= IRGA <= 32767)
C 
C                      1  overflow occurred in the value of IRGA if the 
C                         next character were used.  IRGA ia valid for
C                         the number of characters used so far. 
C 
C                       2  only blanks found before non numeric.
C 
C                       3  only blanks and sign found before non numeric
C                          IRGA = s1 (i. e. +1/-1)
C 
C                       4  255 blanks have been found 
C 
C                       5  ISTRT was greater than IEND upon entry.
C 
C       BUFFER FORMAT ACCEPTED: 
C 
C              bbbbbsbbbnnnnnnnnc 
C 
C             1.  any number of blanks may be before or after sign s s = +/-
C 
C             2.  any number of zeros may preceed the number
C 
C             3.  any non-nummeric character will terminate the conversion
C                 as well as the reasching of IEND. 
C 
C             4.  a check should be made of IRGB upon return since
C                 the format  bbbbsbbbc is accepted also. 
C 
      integer ic,jchar
C 
        equivalence (reg,irga,ireg(1)),(irgb,ireg(2)) 
C 
C 
C               INITIALIZE INTERNAL PARAMETERS
C 
        knumf=.false.
C 
        isign=0 
C 
        ix=0
C 
C               CHECK FOR VALID CALL
C 
        if(istrt.gt.iend) goto 98500
C 
        irga=0
        irgb=0
C 
C               LOOP THROUGH THE CHARACTERS 
C 
        do 70000 ix=istrt,iend
C 
C               SAVE CURRENT INDEX FOR LOOP LEAVING 
C 
        i=ix
C 
C               GET THE CURRENT CHARACTER TO LOOK AT
C 
      ic=jchar(ibuf,i)
C 
C               SEE IF IC IS A NUMBER 
C 
c      if (ic.lt.'30'X.or.'39'X.lt.ic) goto 10000 
      if (ic.lt.0.or.9.lt.ic) goto 10000 
C 
C               IC IS A NUMBER
C 
C               CONVERT IC TO AN INTEGER IN BINARY
C 
      ic=ic-o'60' 
C 
C               NOTE A DIGIT HAS BEEN FOUND 
C 
      knumf=.true. 
C 
C               ASSIGN A SIGN IF NONE FOUND YET 
C 
        if (isign.eq.0) isign=1 
C 
C               CHECK IRGA WILL NOT OVERFLOW
C 
        if (iabs(irga).gt.3277) goto 98100 
C 
C               CHECK FOR THE NEARLY OVERFLOW CASE LEFT 
C 
        if(             iabs(irga) .eq. 3276
     c          .and.  (       (        isign .eq. 1
     c                          .and.   ic .gt. 7       ) 
     c                  .or.   (        isign .eq. -1 
     c                          .and.   ic .gt. 8       )  )
     c          ) goto 98100
C 
C               COMPUTE NEW VALUE - IT IS NOW SAFE
C 
        irga=10*irga+isign*ic 
C 
C               GO GET THE NEXT CHARACTER IF ANY
C 
        goto 70000 
C 
10000   continue
C 
C               HAVE ANY CHARACTERS BEEN FOUND YET
C 
        if (.not.knumf) goto 20000 
C 
C               THE NORMAL FINISH CONDITION HAS OCCURRED
C 
        irgb=i-istrt+1
C 
C               NOW NNORMAL EXIT
C 
        goto 99000 
C 
20000   continue
C 
C               IF THE CURRENT CHARACTER A BLANK
C 
        if (ic.ne.o'40') goto 30000
C 
C               CHECK FOR TOO MANY BLANKS SO FAR
C 
        if (i-istrt.ge.255) goto 98400 
C 
C               NOT TOO MANY BLANKS YET CONTINUE
C 
        goto 70000 
C 
30000   continue
C 
C               HAS A SIGN BEEN FOUND YET 
C 
        if (isign.eq.0) goto 40000 
C 
C               HERE WE HAVE    1. SIGN 
C                               2. NO BLANK 
C                               3. NO NUMERIC YET 
C 
        goto 98300 
C 
40000   continue
C 
C               CHECK FOR A SIGN NOW
C 
        if (ic.eq.o'53') isign=1
C 
        if (ic.eq.o'55') isign=-1 
C 
C               IF SIGN NOT FOUND THE LAST CASE IS EXHAUSTED
C 
        if (isign.eq.0) goto 98200 
C 
70000   continue
C 
C               INCREMENT I IN CASE OF ERROR - FOR PROPER COUNT 
C 
        i=i+1 
C 
C               CHECK FOR INFORMATION FOUND 
C 
        if (isign.eq.0) goto 98200 
C 
C               CHECK MORE THAN SIGN WAS FOUND
C 
        if (.not.knumf) goto 98300 
C 
C               THE NORMAL COMPLETE  EXIT ROUTE 
C 
        irgb=iend-istrt+1 
C 
C               GO BACK 
C 
        goto 99000 
C 
C       ********************************* 
C       *                               * 
C       *       ERROR EXITS             * 
C       *                               * 
C       ********************************* 
C 
98100   continue
C 
C               OVERFLOW
C 
        irgb=o'400'+i-istrt 
C 
        goto 99000 
C 
98200   continue
C 
C               ONLY BLANKS BEFORE NON-NUMERIC OR END 
C 
        irgb=o'1000'+i-istrt
C 
        goto 99000 
C 
98300   continue
C 
C               ONLY BLANKS AND SIGN BEFORE NON-NUMERIC OR END
C 
        irgb=o'1400'+i-istrt
C 
C               RETURN SIGN VALUE IN IRGA 
C 
        irga=isign
C 
        goto 99000 
C 
98400   continue
C 
C               255 BLANKS (WILL THIS EVER OCCUR ?) 
C 
        irgb=o'2000'+i-istrt+1
C 
        goto 99000 
C 
98500   continue
C 
C               ISTRT AFTER IEND
C 
        irgb=o'2400'
C 
99000   continue
C 
C               RETURN INFORMATION FOUND
C 
        gbfas=reg 
C 
        return
        end 
