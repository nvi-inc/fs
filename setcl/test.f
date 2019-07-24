      program test

      integer*2 ibuf(20)

      call char2hol('1992 366 23:59:58.777',ibuf,1,21)
      write(6,9100) ibuf
9100  format(1x,"buffer=",20a2)

      ich=1
      call gtfld(ibuf,ich,21,ic1,ic2)
      nch = ic2-ic1+1
      write(6,9200) ic1,ic2
9200  format(1x,"ic1 ic2 ",2i6) 
      iyr = ias2b(ibuf,ic1,nch)
      write(6,9300) iyr
9300  format(1x,"the year=",i6) 

      ich = ic2+1
      call gtfld(ibuf,ich,21,ic1,ic2)
      nch=ic2-ic1+1
      write(6,9200) ic1,ic2
      idoy = ias2b(ibuf,ic1,nch)
      write(6,9400) idoy
9400  format(1x,"the doy=",i6) 
      
      ich = ic2+1
      call gtfld(ibuf,ich,21,ic1,ic2)
      nch=ic2-ic1+1
      write(6,9200) ic1,ic2

      ic3=iscn_ch(ibuf,ic1,ic2,':')
      write(6,9500) ic3
9500  format(1x,"the location of : is ",i6)
      nch = ic3-ic1
      ihr = ias2b(ibuf,ic1,nch)
      write(6,9600) ihr
9600  format(1x,"the hour = ",i6)

      ic1=ic3+1
      ic3=iscn_ch(ibuf,ic1,ic2,':')
      write(6,9500) ic3
      nch = ic3-ic1
      imin = ias2b(ibuf,ic1,nch)
      write(6,9700) imin
9700  format(1x,"the minutes = ",i6)

      ic1=ic3+1
      ic3=iscn_ch(ibuf,ic1,ic2,'.')
      write(6,9500) ic3
      nch = ic3-ic1
      is = ias2b(ibuf,ic1,nch)
      write(6,9800) is
9800  format(1x,"the seconds = ",i6)

      ic1=ic3+1
      nch = ic2-ic1+1
      ihs = ias2b(ibuf,ic1,nch)
      write(6,9900) ihs
9900  format(1x,"the hseconds = ",i6)




      end
