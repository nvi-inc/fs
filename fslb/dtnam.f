      integer*2 function dtnam(lnam,ifc,ilc)

C   parse module names c#870407:13:00# 
C 
C     DTNAM parses module names entered as parameters in SNAP commands, 
C     outputting the appropriate 2-character mnemonic.
C 
C  INPUT: 
C 
      dimension lnam(1) 
C          - module name to be parsed 
      integer ifc,ilc
C          - ifc  first character position
C          - ilc  last character position
C 
C  OUTPUT:
C 
C     DTNAM - 2-character mnemonic for module name
C 
C  LOCAL VARIABLES: 
C 
      character*80 cicr
      character    cic2
      integer*2  ic2
      integer*2 icr(4)
C          - array of individual characters in LNAM 
C     NC - character position in LNAM 
C     IC2 - 2nd character of mnemonic 
C 
C  CONSTANTS: 
      character*5 cistcr
C 
      data cistcr /'oeivb'/
C          - legal decimal values for 1st character of module name
C 
C  DATE  WHO  CHANGES 
C 840308 MWH  Created 
C 
C 
C  Initialize and transfer control based on first character of module name
      dtnam=0 
      cicr = ' '
      call hol2char(lnam,ifc,ilc,cicr)

      do i=1,9
        if (cicr(1:1).eq.cistcr(i:i)) goto 105 
      enddo
      goto 160   !! if start with a number 0-9 or a,c,d,f
105   goto (110,120,130,140,150) i 
C            o   e   i   v   b
C

110   continue  !! ODD

      if (cicr(1:3).eq.'odd') then
        if (cicr(4:4).eq.'u') then
          call char2hol('ou',dtnam,1,2)
        else if (cicr(4:4).eq.'l') then
          call char2hol('ol',dtnam,1,2)
        else if (cicr(4:4).eq.' ') then
          call char2hol('od',dtnam,1,2)
        endif
      endif
      goto 900 

120   continue   !! EVEN

      if (cicr(1:4).eq.'even') then
        if ((cicr(5:5).eq.'u').and.(cicr(6:6).eq.' ')) then
          call char2hol('vu',dtnam,1,2)
        else if ((cicr(5:5).eq.'l').and.(cicr(6:6).eq.' ')) then
          call char2hol('vl',dtnam,1,2)
        else if (cicr(5:5).eq.' ') then
          call char2hol('ev',dtnam,1,2)
        endif
      else if ((cicr(2:2).eq.'u').and.(cicr(3:3).eq.' ')) then
        call char2hol('eu',dtnam,1,2)
      else if ((cicr(2:2).eq.'l').and.(cicr(3:3).eq.' ')) then
        call char2hol('el',dtnam,1,2)
      endif
      goto 900 

C  Handle IFD's 

130   continue

      nc=2
      if (cicr(nc:nc).eq.'f') nc=3
      if ((cicr(nc:nc).eq.'1').and.(cicr(nc+1:nc+1).eq.' '))
     .  call char2hol('i1',dtnam,1,2)
      if ((cicr(nc:nc).eq.'2').and.(cicr(nc+1:nc+1).eq.' '))
     .  call char2hol('i2',dtnam,1,2)
      if ((cicr(nc:nc).eq.'3').and.(cicr(nc+1:nc+1).eq.' '))
     .  call char2hol('i3',dtnam,1,2)
      if ((cicr(nc:nc).eq.'a').and.(cicr(nc+1:nc+1).eq.' '))
     .  call char2hol('ia',dtnam,1,2)
      if ((cicr(nc:nc).eq.'b').and.(cicr(nc+1:nc+1).eq.' '))
     .  call char2hol('ib',dtnam,1,2)
      if ((cicr(nc:nc).eq.'c').and.(cicr(nc+1:nc+1).eq.' '))
     .  call char2hol('ic',dtnam,1,2)
      if ((cicr(nc:nc).eq.'d').and.(cicr(nc+1:nc+1).eq.' '))
     .  call char2hol('id',dtnam,1,2)

      goto 900 

C  Handle VC's

140   continue

      if (cicr(3:3).eq.' ') then
        if ((cicr(2:2).ge.'1'.and.cicr(2:2).le.'9').or.(cicr(2:2).ge.'a'
     ..and.cicr(2:2).le.'f')) dtnam=lnam(1) 
        goto 900 
      endif
      nc=2
      if (cicr(4:4).ne.' ') nc=3 
      if (cicr(nc:nc).ne.'c'.and.cicr(nc:nc).ne.'0') goto 145
C  IF NC=2 and 2 = C OR 0 THEN DO THE FOLLOWING
      if (cicr(nc+1:nc+1).lt.'1'.or.cicr(nc+1:nc+1).gt.'f'.or.
     .   (cicr(nc+1:nc+1).gt.'9' .and.cicr(nc+1:nc+1).lt.'a')) goto 900 
        cic2=cicr(nc+1:nc+1) 
        goto 147 
145   if (cicr(nc:nc).ne.'1'.or.cicr(nc+1:nc+1).lt.'0'.or.
     .    cicr(nc+1:nc+1).gt.'5') goto 900
        call char2hol(cicr(nc+1:nc+1),ic2,1,1)
        ic2=ic2+49   !! change the number to corresponing letter,
        call hol2char(ic2,1,1,cic2)
C                       i.e. 5 to f
147     call char2hol(cicr(1:1),dtnam,1,1)
        call char2hol(cic2,dtnam,2,2)
       goto 900

150   continue !!! BBC's

      if ((cicr(2:2).eq.'u').or.(cicr(2:2).eq.'l')) then
        call char2hol(cicr(1:2),dtnam,1,2)
      else if (cicr(1:3).eq.'bbc') then    !!! BBC
        if (cicr(4:4).eq.'0') then
          if ((cicr(5:5).ge.'1').and.(cicr(5:5).le.'9')) then
            if (((cicr(6:6).eq.'u').or.(cicr(6:6).eq.'l')).and.
     .           (cicr(7:7).eq.' ')) then
              call char2hol(cicr(5:6),dtnam,1,2)
            endif
          endif
        else if ((cicr(4:4).eq.'1').and.(cicr(5:5).ge.'0').and.
     .                                  (cicr(5:5).le.'5')) then
          call char2hol(cicr(5:5),ic2,1,1)
          ic2=ic2+49
          call hol2char(ic2,1,1,cic2)
          if (((cicr(6:6).eq.'u').or.(cicr(6:6).eq.'l')).and.
     .         (cicr(7:7).eq.' ')) then
            call char2hol(cic2,dtnam,1,1)
            call char2hol(cicr(6:6),dtnam,2,2)
          endif
        else if ((cicr(4:4).ge.'1').and.(cicr(4:4).le.'9').or.
     .           (cicr(4:4).ge.'a').and.(cicr(4:4).le.'f')) then
          if (((cicr(5:5).eq.'u').or.(cicr(5:5).eq.'l')).and.
     .         (cicr(6:6).eq.' ')) then
            call char2hol(cicr(4:4),dtnam,1,1)
            call char2hol(cicr(5:5),dtnam,2,2)
          endif
        endif
      else if (cicr(1:2).eq.'bc') then    !!! BC
        if (cicr(3:3).eq.'0') then    !!! BCnn
          if ((cicr(4:4).ge.'1').and.(cicr(4:4).le.'9')) then
            if (((cicr(5:5).eq.'u').or.(cicr(5:5).eq.'l')).and.
     .           (cicr(6:6).eq.' ')) then
              call char2hol(cicr(4:4),dtnam,1,1)
              call char2hol(cicr(5:5),dtnam,2,2)
            endif
          endif
        else if ((cicr(3:3).eq.'1').and.((cicr(4:4).ge.'0').and.
     .                                   (cicr(4:4).le.'5'))) then
          call char2hol(cicr(4:4),ic2,1,1)
          ic2=ic2+49
          call hol2char(ic2,1,1,cic2)
          if (((cicr(5:5).eq.'u').or.(cicr(5:5).eq.'l')).and.
     .         (cicr(6:6).eq.' ')) then
            call char2hol(cic2,dtnam,1,1)
            call char2hol(cicr(5:5),dtnam,2,2)
          endif
        else if (((cicr(3:3).ge.'1').and.(cicr(3:3).le.'9')).or.
     .           ((cicr(3:3).ge.'a').and.(cicr(3:3).le.'f'))) then
C    !!! BCn
          if (((cicr(4:4).eq.'u').or.(cicr(4:4).eq.'l')).and.
     .         (cicr(5:5).eq.' ')) then
            call char2hol(cicr(3:3),dtnam,1,1)
            call char2hol(cicr(4:4),dtnam,2,2)
          endif
        endif
      else if (cicr(1:1).eq.'b') then    !!! B
        if (cicr(2:2).eq.'0') then 
          if ((cicr(3:3).ge.'1').and.(cicr(3:3).le.'9')) then
            if (((cicr(4:4).eq.'u').or.(cicr(4:4).eq.'l')).and.
     .           (cicr(5:5).eq.' ')) then
              call char2hol(cicr(3:3),dtnam,1,1)
              call char2hol(cicr(4:4),dtnam,2,2)
            endif
          endif
        else if ((cicr(2:2).eq.'1').and.((cicr(3:3).ge.'0').and.
     .                                   (cicr(3:3).le.'5'))) then
          call char2hol(cicr(3:3),ic2,1,1)
          ic2=ic2+49
          call hol2char(ic2,1,1,cic2)
          if (((cicr(4:4).eq.'u').or.(cicr(4:4).eq.'l')).and.
     .         (cicr(5:5).eq.' ')) then
            call char2hol(cic2,dtnam,1,1)
            call char2hol(cicr(4:4),dtnam,2,2)
          endif
        else if (((cicr(2:2).ge.'1').and.(cicr(2:2).le.'9')).or.
     .           ((cicr(2:2).ge.'a').and.(cicr(2:2).le.'f'))) then
          if (((cicr(3:3).eq.'u').or.(cicr(3:3).eq.'l')).and.
     .         (cicr(4:4).eq.' ')) then
            call char2hol(cicr(2:2),dtnam,1,1)
            call char2hol(cicr(3:3),dtnam,2,2)
          endif
        endif
      endif
      goto 900 

C  Take care of other baseband detectors not leading with a "b"

160   continue

      if (cicr(1:1).eq.'0') then    !!! BBCnn
        if ((cicr(2:2).ge.'1').and.(cicr(2:2).le.'9')) then
          if ((cicr(3:3).eq.'u').or.(cicr(3:3).eq.'l')) then
            if (cicr(4:4).eq.' ') then
              call char2hol(cicr(2:2),dtnam,1,1)
              call char2hol(cicr(3:3),dtnam,2,2)
            endif
          endif
        endif
      else if ((cicr(1:1).eq.'1').and.(cicr(2:2).ge.'0').and.
     .                                (cicr(2:2).le.'5')) then
        if ((cicr(3:3).eq.'u').or.(cicr(3:3).eq.'l')) then
          call char2hol(cicr(2:2),ic2,1,1)
          ic2=ic2+49
          call hol2char(ic2,1,1,cic2)
          if (cicr(4:4).eq.' ') then
            call char2hol(cicr(3:3),dtnam,2,2)
            call char2hol(cic2,dtnam,1,1)
          endif
        endif
      else if (((cicr(1:1).ge.'1').and.(cicr(1:1).le.'9')).and.
     .         ((cicr(2:2).eq.'u').or.(cicr(2:2).eq.'l'))) then
        if (cicr(3:3).eq.' ') then
          call char2hol(cicr(1:2),dtnam,1,2)
        endif
      else if ((cicr(1:1).ge.'a').and.(cicr(1:1).le.'f')) then
        if ((cicr(2:2).eq.'u').or.(cicr(2:2).eq.'l')) then
          if (cicr(3:3).eq.' ') then
            call char2hol(cicr(1:2),dtnam,1,2)
          endif
        endif
      endif
      goto 900 

C  Return to calling routine

900   continue
      return
      end 
