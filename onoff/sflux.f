	program sflux
CC
        real nu, array, lognu, flux, logflux, oflux(16)
        real month, year, epoch, flux80
        integer nsource
        dimension array(1:6,1:17)
        character*8  sname(17), oname(17)
CC
        data array / 1350, 23780, 2.465, -0.004, -0.1251, 1.5,
     1    1350, 23780, 2.525, 0.246, -0.1638, 23,
     2    1350, 23780, 2.806, -0.140, -0.1031, 1,
     3    1350, 10550, 1.250, 0.726, -0.2286, 3, 
     4    1350, 10550, 4.729, -1.025, 0.0130, 47,
     5    1350, 5000,  6.757, -2.801, 0.2969, 200,
     6    1350, 5000,  2.537, -0.565, -0.0404, 15,
     7    1350, 10550, 4.484, -0.603, -0.0280, 200,
     8    1350, 43200, 0.956, 0.584, -0.1644, 1.5,
     9    1350, 32000, 1.490, 0.756, -0.2545, 5,
     A    1350, 32000, 2.617, -0.437, -0.0373, 1.5,
     B    1350, 10550, 3.852, -0.361, -0.1053, 170,
     C    1350, 10550, 3.148, -0.157, -0.0911, 210,
     D      20, 2000, 4.695,  0.085, -0.178, 115,
     E    2000, 31000, 7.161, -1.244, 0.0, 115,
     F    1000, 35000, 3.915, -0.299, 0.0, 300,
     G    10550, 43200, 1.322, -0.134, 0, 10 /
CC
        data sname/'3c48','3c123','3c147','3c161','3c218',
     1     '3c227', '3c249.1','Vir A','3c286','3c295',
     2     '3c309.1','3c348','3c353','Cyg A','Cyg A',
     3     'Tau A','NGC7027' /   
CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC
CC
        print *, 'This program calculates source flux densities'
        print *, 'for low variability sources.'
        print *, ' '
 
        print *, 'For Secondary Calibrators  and Virgo A it uses' 
        print *, 'the spectra given by Ott et al 1994, AA 284,331'
        print *, ' '
 
        print *, 'For the primary calibrators (Cas A, Cygnus A, Tau A)'
        print *, 'it uses Baars et al 1977, AA 61,91'
        print *, ' '

        print *, 'Up to date flux densities of variable sources, 3C84'
        print *, '3C273 etc can be found at 4.8,8 and 14.5 GHz from' 
        print *, 'the Univ of Michigan data base. This can be found at'
      print *, 'http://www.astro.lsa.umich.edu/obs/radiotel/umrao.html'
        print *, ' '
CC
CC     What is the Observing frequency?
CC
       print *, ' what is the observing frequency (MHz)'   
        read (*,*) nu
        print *, ' ' 
CC
CC     What is the Observing Epoch?
CC
5      print *, ' what is the observing epoch'
       print *, ' Give year, four digits and month seperated by space'
CC
       read (*,*) year, month
       epoch = year + (month/12.0)
CC
       if (year.le.1900) then
          print *, 'Need four digits for the year'
          goto 5
       else
       end if
CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC
CC     Find sources with accurate spectra at this frequency
CC      and calculate flux density
CC
       print *, ' '
       print *, 'Source Flux densities (Jy) at', nu, '(MHz)'
       print *, 'at epoch', epoch 
       print *, ' '
CC
       print *, 'Source', '   Flux (Jy)', '  Largest Dimension (")'
       print *, ' '
CC     
        do 100 i=1,16
CC
         if ((nu.ge.array(1,i)).and.(nu.le.array(2,i))) then 
            nsource = nsource + 1
            lognu = log10(nu) 
            logflux = array(3,i) + lognu*array(4,i) + 
     1         (lognu**2)*array(5,i)
            flux = 10.0**(logflux)
            write(6,10) sname(i), flux, array(6,i)
         else 
CC
         endif       
CC
100      continue
CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC
CC     Do special calculation for Cas A, based on Baars et al 
CC     paper, to take account of flux variation with time
CC
         if ((nu.ge.300).and.(nu.le.31000)) then       
CC       
CC       First  Calculate 1980.0 flux density

         lognu = log10(nu) 
         logflux = 5.745 - 0.770*lognu
         flux80 = 10.0**(logflux)
CC
CC       Calculate flux density at epoch of observations
CC
          dflux = 1 - ( (0.97 - 0.30*(lognu-3)) /100.0)
         flux = flux80* (10**((epoch-1980.0)*log10(dflux)))
         write(6,10) 'Cas A', flux, 180.0 
CC
        else
        end if
CC
CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
CC
10	FORMAT(2X,A7,3X,F7.2,3X,F7.2) 
CC
30	end
CC










