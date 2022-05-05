#!/usr/bin/perl
open(fi,"/tmp/DRlab.tmp");
#Print labels to Dymo from /tmp/DRlab.tmp, separates individual labels,
#makes encapsulated postscript , uses gs to make pbm files (beware
#old gs versions, they dont do that correctly)
#/dev/usblp0 should open as soon as Dymo is connected to USB.
#====================Packages needed========================
#pnmnoraw is from netpbm package
#pbm2lwxl from http://www.freelabs.com/~whitis/software/pbm2lwxl/
#===========================================================
# scale and numbers to take off x and y before scale, fontsize
$scale=1.3; $xoff=25; $yoff=-20; $fontsize=10;
$fil=0; $ignore_misplaced=0;
while(<fi>){
  chomp;
  (@ss)=split();
  $inline=$_;
  if(substr($_,0,10) eq "\%\!PS-Adobe"){$ignore_misplaced = 1; $done_prolog=0;}
  if($ss[2] eq "moveto"){
     $ignore_misplaced = 0;
     if($done_prolog == 0){
          $linewidth=0.6;
	  $lw=sprintf("%1.2f ",$linewidth);
	  print (fo "%!PS-Adobe-2.0 EPSF-2.0\n");
	  print (fo "%%BoundingBox: 0 10 100 220\n");
  	  print (fo "%%HiResBoundingBox: 0.000000 10.000000 100.000000 220.000000\n");
	  print (fo "%EndProlog\n");
	  print (fo "%%EndComments\n");
	  print (fo "%%Page 1 1\n");
	  print (fo "/Helvetica findfont\n");
	  print (fo "10 scalefont\n");
	  print (fo " setfont\n");
	  print (fo "0 setgray\n", $lw," setlinewidth\n 90 rotate \n");
	  $done_prolog=1;
     }
  }
  if(substr($_,5,5) eq "Adobe"){
# if not first label, send out previous
     if($fil != 0){
        &dymout;
     }
     # open temporary ps file for each label
     $fil++;
     open(fo,">/tmp/dymo.ps");
  }
  if($ignore_misplaced != 1){
# presently label is a wee bit small, so scale the xy
    if($ss[1] eq "scalefont"){$inline=sprintf("%d scalefont ", $fontsize);}
    if(($ss[2] eq "moveto") || ($ss[2] eq "lineto")){
        $x1=($ss[0]-$xoff)*$scale; 
        $y1=($ss[1]-$yoff)*$scale; 
	$inline=sprintf("%6.1f %6.1f %s ", $x1,$y1,$ss[2]);
    }
    if(($ss[0] ne "showpage") && ($ss[0] ne "%%Trailer")){
      print(fo $inline,"\n");
    }
  }
}
&dymout; # send out final label
sub dymout {
# close temporary ps and send to printer
print(fo "showpage\n\%\%Trailer\n");
print(fo "cleartomark\ncountdictstack\n");
print(fo "exch sub { end } repeat\n");
print(fo "restore\n");
print(fo "%%EOF\n");
close(fo);
#Next line sends to a pbm file for testing purposes
#`gs -q -dNOPAUSE -dSAFER -g400x900 -r300x300  -sDEVICE=pbm -sOutputFile=- /tmp/dymo.ps -c quit |  pnmnoraw   >/tmp/x$fil.pbm`;
#If really sending to dymo: use this:
`gs -q -dNOPAUSE -dSAFER -g400x900 -r300x300  -sDEVICE=pbm -sOutputFile=- /tmp/dymo.ps -c quit | pnmnoraw | pbm2lwxl 400 900 >/dev/usb/lp0`;
unlink('/tmp/dymo.ps');
}
