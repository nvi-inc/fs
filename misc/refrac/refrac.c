/*
 * Copyright (c) 2021 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include <stdio.h>
#include <math.h>

double refrw(), refrwn();
double sbend();
double lanyi();

int main()
{
    int i;
    float temp,pres,humi;
    double el,delta;
    double el2, delta2, el3, diff;
    double delta3,diff2,diff3,delta4,diff4;

    printf("correcting refracted angle vs correcting unrefracted\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el   lanyi  el+lanyi lanyi2  el+lanyi-lanyi2 lanyi-lanyi2\n");

    for (i=1; i<=11;i++) {
        el=i*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        el2=el+delta;
        delta2=lanyi(el2,temp,humi,pres);
        el3=el2-delta2;
        diff=el3-el;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        el*=180./M_PI;
        diff*=180./M_PI;
        el2*=180./M_PI;
        el3*=180./M_PI;
        printf(" %6.3lf  %.3lf  %6.3lf   %.3lf      %6.3lf          %.3lf\n",
                el,delta,el2,delta2,el3,diff);
    }

    printf("\nincorrect refrw.c vs correct refrwn.c\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el   lanyi  refrw refrwn refrw-lanyi refrwn-lanyi refrwn-refrw\n");

    for (i=1; i<=11;i++) {
        el=i*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        delta2=refrw(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,delta,delta2,delta3,diff2,diff3,diff4);
    }

    printf("\n0-100 humidity\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el    humi  lanyi  refrw refrwn refrw-lanyi refrwn-lanyi refrwn-refrw\n");

    for(i=0;i<=100;i+=10) {
        el=5*M_PI/180.;
        humi=i;
        delta=lanyi(el,temp,humi,pres);
        delta2=refrw(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.1lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,humi,delta,delta2,delta3,diff2,diff3,diff4);
    }

    printf("\n-40c to +40c\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el    temp  lanyi  refrw refrwn refrw-lanyi refrwn-lanyi refrwn-refrw\n");

    for(i=-40;i<=+40;i+=10) {
        el=5*M_PI/180.;
        temp=i;
        delta=lanyi(el,temp,humi,pres);
        delta2=refrw(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.1lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,temp,delta,delta2,delta3,diff2,diff3,diff4);
    }

    printf("\n970mb to 1040 mb\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el    pres  lanyi  refrw refrwn refrw-lanyi refrwn-lanyi refrwn-refrw\n");

    for(i=970;i<=+1040;i+=10) {
        el=5*M_PI/180.;
        pres=i;
        delta=lanyi(el,temp,humi,pres);
        delta2=refrw(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.1lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,pres,delta,delta2,delta3,diff2,diff3,diff4);
    }
    printf("\nsbend.c vs refrwn.c\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el   lanyi  sbend refrwn sbend-lanyi refrwn-lanyi refrwn-sbend\n");

    for (i=1; i<=11;i++) {
        el=i*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        delta2=sbend(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,delta,delta2,delta3,diff2,diff3,diff4);
    }

    printf("\n0-100 humidity\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el    humi  lanyi  sbend refrwn sbend-lanyi refrwn-lanyi refrwn-sbend\n");

    for(i=0;i<=100;i+=10) {
        el=5*M_PI/180.;
        humi=i;
        delta=lanyi(el,temp,humi,pres);
        delta2=sbend(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.1lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,humi,delta,delta2,delta3,diff2,diff3,diff4);
    }

    printf("\n-40c to +40c\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el    temp  lanyi  sbend refrwn sbend-lanyi refrwn-lanyi refrwn-sbend\n");

    for(i=-40;i<=+40;i+=10) {
        el=5*M_PI/180.;
        temp=i;
        delta=lanyi(el,temp,humi,pres);
        delta2=sbend(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.1lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,temp,delta,delta2,delta3,diff2,diff3,diff4);
    }

    printf("\n970mb to 1040 mb\n");
    pres=1000.;
    humi=50.;
    temp=20.;
    printf("    el    pres  lanyi  sbend refrwn sbend-lanyi refrwn-lanyi refrwn-sbend\n");

    for(i=970;i<=+1040;i+=10) {
        el=5*M_PI/180.;
        pres=i;
        delta=lanyi(el,temp,humi,pres);
        delta2=sbend(el,temp,humi,pres);
        delta3=refrwn(el,temp,humi,pres);
        el*=180./M_PI;
        diff2=delta2-delta;
        diff3=delta3-delta;
        diff4=delta3-delta2;
        delta*=180./M_PI;
        delta2*=180./M_PI;
        delta3*=180./M_PI;
        diff*=180./M_PI;
        diff2*=180./M_PI;
        diff3*=180./M_PI;
        diff4*=180./M_PI;
        printf(" %6.3lf %6.1lf %6.3lf %6.3lf %6.3lf    %6.3lf       %6.3lf       %6.3lf\n",
                el,pres,delta,delta2,delta3,diff2,diff3,diff4);
    }

    printf("\nlanyi.c to compare to JPL IOM 335.3-89-026\n");
    temp=0;
    pres=1013.25;
    humi=0;
    printf(" tempC %lf pres %lf humi %lf\n",temp,pres,humi);
    printf("    el   delta  lanyi (asec)\n");

    for(i=90;i>=80;i--) {
        el=i*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        el*=180./M_PI;
        delta*=180./M_PI;
        printf(" %6.3lf %6.3lf %9.4lf\n",el,delta,delta*3600.);
    }
    for(i=78;i>=20;i-=2) {
        el=i*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        el*=180./M_PI;
        delta*=180./M_PI;
        printf(" %6.3lf %6.3lf %9.4lf\n",el,delta,delta*3600.);
    }
    for(i=19;i>=10;i--) {
        el=i*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        el*=180./M_PI;
        delta*=180./M_PI;
        printf(" %6.3lf %6.3lf %9.4lf\n",el,delta,delta*3600.);
    }
    for(i=94;i>=54;i-=5) {
        el=i*0.1*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        el*=180./M_PI;
        delta*=180./M_PI;
        printf(" %6.3lf %6.3lf %9.4lf\n",el,delta,delta*3600.);
    }
    for(i=50;i>=30;i-=5) {
        el=i*0.1*M_PI/180.;
        delta=lanyi(el,temp,humi,pres);
        el*=180./M_PI;
        delta*=180./M_PI;
        printf(" %6.3lf %6.3lf %9.4lf\n",el,delta,delta*3600.);
    }
}
