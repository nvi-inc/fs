      subroutine papvl (date,ct,elm,emm,eom,alm,ds,els,ems,elven)
C
      implicit double precision (a-h,o-z)
      dimension a(33)
C
      include '../include/dpi.i'
C
      data rps/0.48481368110954d-5/
      data y,d1,d2/36525.d0,3600.d0,60.d0/
C     COMPUTES ARGUMENTS FOR A GIVEN JULIAN DATE
C     T= JULIAN DAYS FROM JAN 1.5,2000
      t=date-2451545.d0
C     CT=JULIAN CENTURIES FROM 1900.D0
      ct=(date-2415020.d0)/36525.d0 
C 
C     A(I) ARE IN UNITS OF REVOLUTIONS
      a( 1)= +0.606434d0 +0.03660110129d0*t 
      a( 2)= +0.374897d0 +0.03629164709d0*t 
      a( 5)= +0.347343d0 -0.00014709391d0*t 
      a( 3)= +0.259091d0 +0.03674819520d0*t 
      a( 4)= +0.827362d0 +0.03386319198d0*t 
      a( 7)= +0.779072d0 +0.00273790931d0*t 
      a( 8)= +0.993126d0 +0.00273777850d0*t 
      a( 9)= +0.700695d0 +0.01136771400d0*t 
      a(10)= +0.485541d0 +0.01136759566d0*t 
      a(11)= +0.566441d0 +0.01136762384d0*t 
      a(12)= +0.505498d0 +0.00445046867d0*t 
      a(13)= +0.140023d0 +0.00445036173d0*t 
      a(14)= +0.292498d0 +0.00445040017d0*t 
      a(15)= +0.987353d0 +0.00145575328d0*t 
      a(16)= +0.053856d0 +0.00145561327d0*t 
      a(17)= +0.849694d0 +0.00145569465d0*t 
      a(18)= +0.089608d0 +0.00023080893d0*t 
      a(19)= +0.056531d0 +0.00023080893d0*t 
      a(20)= +0.814794d0 +0.00023080893d0*t 
      a(21)= +0.133295d0 +0.00009294371d0*t 
      a(22)= +0.882987d0 +0.00009294371d0*t 
      a(23)= +0.821218d0 +0.00009294371d0*t 
      a(24)= +0.870169d0 +0.00003269438d0*t 
      a(25)= +0.400589d0 +0.00003269438d0*t 
      a(26)= +0.664614d0 +0.00003265562d0*t 
      a(27)= +0.846912d0 +0.00001672092d0*t 
      a(28)= +0.725368d0 +0.00001672092d0*t 
      a(29)= +0.480856d0 +0.00001663715d0*t 
      a(31)= +0.663854d0 +0.00001115482d0*t 
      a(32)= +0.041020d0 +0.00001104864d0*t 
      a(33)= +0.357355d0 +0.00001104864d0*t 
      a(6)=0.d0 
      a(30)=0.d0
C 
C     CONVERT A(I) INTO UNITS OF RADIANS
      do i=1,33
        a(i)=a(i)*dtwopi
      enddo
C     CONVERT ANGLES SO THAT THEY ARE LESS THAN OR EQUAL TO 2.D0*PIE
      elm=dmod(a(1),dtwopi)
      emm=dmod(a(2),dtwopi)
      alm=dmod(a(3),dtwopi)
       ds=dmod(a(4),dtwopi)
      eom=dmod(a(5),dtwopi)
      els=dmod(a(7),dtwopi)
      ems=dmod(a(8),dtwopi)
      elmer=dmod(a( 9),dtwopi) 
      emmer=dmod(a(10),dtwopi) 
      almer=dmod(a(11),dtwopi) 
      elven=dmod(a(12),dtwopi) 
      emven=dmod(a(13),dtwopi) 
      alven=dmod(a(14),dtwopi) 
      elmar=dmod(a(15),dtwopi) 
      emmar=dmod(a(16),dtwopi) 
      almar=dmod(a(17),dtwopi) 
      eljup=dmod(a(18),dtwopi) 
      emjup=dmod(a(19),dtwopi) 
      aljup=dmod(a(20),dtwopi) 
      elsat=dmod(a(21),dtwopi) 
      emsat=dmod(a(22),dtwopi) 
      alsat=dmod(a(23),dtwopi) 
      elura=dmod(a(24),dtwopi) 
      emura=dmod(a(25),dtwopi) 
      alura=dmod(a(26),dtwopi) 
      elnep=dmod(a(27),dtwopi) 
      emnep=dmod(a(28),dtwopi) 
      alnep=dmod(a(29),dtwopi) 
      elplu=dmod(a(31),dtwopi) 
      emplu=dmod(a(32),dtwopi) 
      alplu=dmod(a(33),dtwopi) 
C
      return
      end 
