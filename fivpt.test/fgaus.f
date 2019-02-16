      function fgaus(iwhich,x,x2,par) 
C 
C     THREE-PARAMETER SINGLE GAUSSIAN + LINEAR FUNCTION IN 2ND COORDIANTE 
C 
      dimension par(1)
C 
      if(abs(par(3)).lt.abs((x-par(2)))*1.d-30) then
         call put_stderr(' fp error gauss 1\n'//char(0))
        e=0.0
      else
        e=(x-par(2))/par(3) 
      endif
      w=exp(-2.7725887*e*e) 
      goto (20,40,60,80,100,120), iwhich+1 
20    fgaus=par(1)*w+par(4)+par(5)*x2 
      return
40    fgaus=w 
      return
60    fgaus=5.5451774*par(1)*e*w/par(3) 
      return
80    fgaus=5.5451774*par(1)*e*e*w/par(3) 
      return
100   fgaus=1.
      return
120   fgaus=x2

      return
      end 
