#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/rxgain_ds.h"

#define STL(dest,source) min(sizeof((dest)),strlen((source))+1)

#define MAXRX 6
#define MAXDETECTORS 32
#define BADVALUE -600000000
#define BADSTRVALUE "X"
#define MAXLINE 256

int min(int x, int y);

int main(int argc, char *argv[])
{
  char onoffFileName[64], *cptr;
  char parsedFileName[64];
  char rxgFileName[20];
  double azimuth, elevation, skyfreq, gainc, tsys, sefd, tcaljy, tcalk, calratio, tcal_ass;
  double flux_ass, tcalk_over_jy_ass, gcurve_ass, dpfu_gcurve_ass, LO;
  char onetime[22], time[22], source[11], dummy[31], detector[3], ifchan[2], polarization[2], sourcetype[2];
  char source_array[MAXDETECTORS][11], detector_array[MAXDETECTORS][3];
  char ifchan_array[MAXDETECTORS][2], polarization_array[MAXDETECTORS][2], sourcetype_array[MAXDETECTORS][2];
  char namearray[MAXRX][20], typearray[MAXRX][6];
  double azimuth_array[MAXDETECTORS], elevation_array[MAXDETECTORS], skyfreq_array[MAXDETECTORS];
  double gainc_array[MAXDETECTORS], tsys_array[MAXDETECTORS], sefd_array[MAXDETECTORS];
  double tcaljy_array[MAXDETECTORS], tcalk_array[MAXDETECTORS], calratio_array[MAXDETECTORS];
  double tcal_ass_array[MAXDETECTORS], flux_ass_array[MAXDETECTORS], dpfu_ass_array[MAXDETECTORS];
  double gcurve_ass_array[MAXDETECTORS], dpfu_gcurve_ass_array[MAXDETECTORS], LO_array[MAXDETECTORS];
  double LO1array[MAXRX], LO2array[MAXRX];
  int detcount, valcount, i, right, firstapr, firstval, rxcount, error, work;
  char name[32], type[10];
  double LO1, LO2;
  FILE *onoffFile;
  FILE *parsedFile;
  FILE *rxgFile;
  char line[1000];     /* line buffer for fgets() */
  struct rxgain_ds rxgain[MAXRX];
  detcount=0;
  valcount=0;
  right=0;
  firstapr=1;
  firstval=1;
  rxcount=0;
  strncpy(onoffFileName,argv[1],STL(onoffFileName,argv[1]));
  strncpy(parsedFileName,argv[2],STL(parsedFileName,argv[2]));
  work = ((int) argv[3]);
  onoffFile = fopen(onoffFileName, "r");
  if(onoffFile == NULL)
    {
      printf("Error opening file: %s", onoffFileName);
      exit(0);
    }
  
  parsedFile = fopen(parsedFileName, "w");
  if(parsedFile == NULL)
    {
      printf("Error opening file parsed.txt");
      exit(0);
    }
  fputs("$ANTENNA\n", parsedFile);
  
  fputs("* LEADING STAR OR SOMETHING IS A COMMENT\n", parsedFile);
  fputs("$DPFU\n", parsedFile);
  fputs("lcp 8.1 rcp 8.2\n", parsedFile);
  fputs("$GAIN\n", parsedFile);
  fputs("ELEV POLY 0 1 2 -0.5\n", parsedFile);
  fputs("$LABELS\n", parsedFile);
  fputs("Time\n", parsedFile);
  fputs("Source\n", parsedFile);
  fputs("Azimuth\n", parsedFile);
  fputs("Elevation\n", parsedFile);
  fputs("Detector\n", parsedFile);
  fputs("IF Channel\n", parsedFile);
  fputs("Polarization\n", parsedFile);
  fputs("Frequency\n", parsedFile);
  fputs("Gain Compression\n", parsedFile);
  fputs("Tsys\n", parsedFile);
  fputs("SEFD\n", parsedFile);
  fputs("TCal(Jy)\n", parsedFile);
  fputs("TCal(K)\n", parsedFile);
  fputs("TCal Ratio\n", parsedFile);
  fputs("Gain\n", parsedFile);
  fputs("Assumed TCal(K)\n", parsedFile);
  fputs("Assumed Source Flux\n", parsedFile);
  fputs("Assumed DPFU\n", parsedFile);
  fputs("Assumed Gain Curve\n", parsedFile);
  fputs("Assumed DPFU*Gain Curve\n", parsedFile);
  fputs("LO\n", parsedFile);
  fputs("SourceType\n", parsedFile);
  fputs("*\n", parsedFile);
  
  fputs("$DATA\n", parsedFile);
  while (fgets(line, MAXLINE, onoffFile) != NULL) {
    if(strstr(line,"/calrx/") != NULL) {
      if((NULL == (cptr = strtok(line," /,")) || (1!=sscanf(cptr, "%20s", time)))) {
	strcpy(time,BADSTRVALUE);
      }
      if((NULL == (cptr = strtok(NULL," /,")) || (1!=sscanf(cptr, "%s", source)))) {
	strcpy(source,BADSTRVALUE);
      }
      if((NULL == (cptr = strtok(NULL," /,")) || (1!=sscanf(cptr, "%s", name)))) {
	strcpy(name,BADSTRVALUE);
      }
      if((NULL == (cptr = strtok(NULL," /,")) || (1!=sscanf(cptr, "%s", type)))) {
	strcpy(type,BADSTRVALUE);
      }
      if(NULL == (cptr = strtok(NULL," /,")) || (1!=sscanf(cptr, "%lf", &LO1)) || LO1 <= 0) {
	LO1 = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," /,")) || (1!=sscanf(cptr, "%lf", &LO2)) || LO2 <= 0) {
	LO2 = BADVALUE;
      }
      strncpy(namearray[rxcount],name,min(MAXDETECTORS,strlen(name))+1);
      strncpy(typearray[rxcount],type,min(MAXDETECTORS,strlen(type))+1);
      LO1array[rxcount] = LO1;
      LO2array[rxcount] = LO2;

      strcpy(rxgFileName,FS_ROOT);
      strcat(rxgFileName,"/control/");
      strcat(rxgFileName,namearray[rxcount]);
      strcat(rxgFileName,".rxg");
      if(work == 1) {
	strcat(rxgFileName,".work");
      }
      rxgFile = fopen(rxgFileName, "r");
      if(rxgFile == NULL)
	{
	  fclose(rxgFile);
	  exit(-1);
	}
      fclose(rxgFile);      
      error = get_rxgain(rxgFileName, &rxgain[rxcount]);
      /*printf("error %d name %s type %c \n",error,rxgFileName,rxgain[rxcount].type);*/
      rxcount++;

    }
    if(strstr(line,";onoff\n") != NULL) {
      for (i=0; i<=detcount; i++) {
	strcpy(detector_array[i],"NULL");
      }
      if((NULL == (cptr = strtok(line," \t\n")) || (1!=sscanf(cptr, "%20s", onetime)))) {
	strcpy(onetime,BADSTRVALUE);
      }
      detcount=0;
      
    }
    if(strstr(line,"APR") != NULL) {
      if(firstapr==1) {
	detcount=0;
	firstapr=0;
	firstval=1;
      }
      if((NULL == (cptr = strtok(line," \t\n")) || (1!=sscanf(cptr, "%20s", time)))) {
	strcpy(time,BADSTRVALUE);
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%s", detector))) {
	strcpy(detector,BADSTRVALUE);
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &skyfreq)) || skyfreq <= 0) {
	skyfreq = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &tcal_ass)) || tcal_ass <= 0) {
	tcal_ass = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &flux_ass)) || flux_ass <= 0) {
	flux_ass = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &tcalk_over_jy_ass)) || tcalk_over_jy_ass <= 0) {
	tcalk_over_jy_ass = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &gcurve_ass)) || gcurve_ass <= 0) {
	gcurve_ass = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &dpfu_gcurve_ass)) || dpfu_gcurve_ass < 0) {
	dpfu_gcurve_ass = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &LO)) || LO <= 0) {
	LO = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%s", sourcetype))) {
	strcpy(sourcetype,BADSTRVALUE);
      }
      strncpy(detector_array[detcount],detector,min(MAXDETECTORS,strlen(detector))+1);
      skyfreq_array[detcount] = skyfreq;
      tcal_ass_array[detcount] = tcal_ass;
      flux_ass_array[detcount] = flux_ass;
      dpfu_ass_array[detcount] = tcalk_over_jy_ass;
      gcurve_ass_array[detcount] = gcurve_ass;
      dpfu_gcurve_ass_array[detcount] = dpfu_gcurve_ass;
      LO_array[detcount] = LO;
      strncpy(sourcetype_array[detcount],sourcetype,min(MAXDETECTORS,strlen(sourcetype))+1);
      detcount++;
    }
    if(strstr(line,"VAL") != NULL) {
      if(firstval==1) {
	valcount=0;
	firstval=0;
	firstapr=1;
      }
      if((NULL == (cptr = strtok(line," \t\n")) || (1!=sscanf(cptr, "%20s", time)))) {
	  strcpy(time,BADSTRVALUE);
      }
      if((NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%s", source)))) {
	strcpy(source,BADSTRVALUE);
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &azimuth)) || azimuth <= 0) {
	azimuth = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &elevation)) || elevation <= 0) {
	elevation = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%s", detector))) {
	strcpy(detector,BADSTRVALUE);
      }
      if((NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%s", ifchan)))) {
	strcpy(ifchan,BADSTRVALUE);
      }
      if((NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%s", polarization)))) {
	strcpy(polarization,BADSTRVALUE);
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &skyfreq)) || skyfreq <= 0) {
	skyfreq = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &gainc)) || gainc <= 0) {
	gainc = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &tsys)) || tsys <= 0) {
	tsys = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &sefd)) || sefd <= 0) {
	sefd = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &tcaljy)) || tcaljy <= 0) {
	tcaljy = BADVALUE;
      }
      /*if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &tcalk)) || tcalk <= 0) {
	tcalk = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &calratio)) || calratio <= 0) {
	calratio = BADVALUE;
	}*/
      strncpy(source_array[valcount],source,min(MAXDETECTORS,strlen(source))+1);
      azimuth_array[valcount] = azimuth;
      elevation_array[valcount] = elevation;
      strncpy(ifchan_array[valcount],ifchan,min(MAXDETECTORS,strlen(ifchan))+1);
      strncpy(polarization_array[valcount],polarization,min(MAXDETECTORS,strlen(polarization))+1);
      gainc_array[valcount] = gainc;
      tsys_array[valcount] = tsys;
      sefd_array[valcount] = sefd;
      tcaljy_array[valcount] = tcaljy;
      /*tcalk_array[valcount] = tcalk;
	calratio_array[valcount] = calratio;*/
      for (i=0; i<=detcount; i++) {
	if(strcmp(detector,detector_array[i])==0) {
	  float fwhm,dpfu,gain,tcal;
	  /*printf(" rxcount %d LO %f sky %f elev %f pol %c\n",
	    rxcount,LO_array[i],skyfreq_array[i],elevation_array[valcount],polarization_array[valcount][0]);*/
	  get_gain_par2(&rxgain,rxcount,LO_array[i],skyfreq_array[i],1.0,elevation_array[valcount],polarization_array[valcount][0],&fwhm,&dpfu,&gain,&tcal);
	  tcal_ass_array[i]=tcal;
	  dpfu_ass_array[i]=dpfu;
	  gcurve_ass_array[i]=gain;
	  if(tcaljy_array[i]<0) {
	    tcalk_array[i]=BADVALUE;
	    calratio_array[valcount]=BADVALUE;
	  } else {
	    tcalk_array[i]=dpfu*tcaljy_array[i]*gain;
	    /*printf("%lf %lf %lf %lf\n",dpfu,tcal,fwhm,gain);*/
	    calratio_array[valcount]=100*(tcalk_array[i]/tcal_ass_array[i]);
	  }
	  dpfu_gcurve_ass_array[i]=dpfu*gain;
	  
	  /*printf(" fwhm %f dpfu %f gain %f tcal %f\n",fwhm*RAD2DEG,dpfu,gain,tcal);*/
	  fprintf(parsedFile, "%s ", onetime);
	  fprintf(parsedFile, "%s ", source_array[valcount]);
	  fprintf(parsedFile, "%.1f ", azimuth_array[valcount]);
	  fprintf(parsedFile, "%.1f ", elevation_array[valcount]);
	  fprintf(parsedFile, "%s ", detector_array[i]);
	  fprintf(parsedFile, "%s ", ifchan_array[valcount]);
	  fprintf(parsedFile, "%s ", polarization_array[valcount]);
	  fprintf(parsedFile, "%.1f ", skyfreq_array[i]);
	  fprintf(parsedFile, "%.2f ", gainc_array[valcount]);
	  fprintf(parsedFile, "%.2f ", tsys_array[valcount]);
	  fprintf(parsedFile, "%.1f ", sefd_array[valcount]);
	  fprintf(parsedFile, "%.3f ", tcaljy_array[valcount]);
	  fprintf(parsedFile, "%.3f ", tcalk_array[valcount]);
	  fprintf(parsedFile, "%.2f ", calratio_array[valcount]);
	  if(tcaljy_array[i]<0) {
	    fprintf(parsedFile, "%.2f ", BADVALUE);
	  } else {
	    fprintf(parsedFile, "%.4f ", tcal_ass_array[i]/tcaljy_array[valcount]);
	  } 
	  fprintf(parsedFile, "%.3f ", tcal_ass_array[i]);
	  fprintf(parsedFile, "%.1f ", flux_ass_array[i]);
	  fprintf(parsedFile, "%.4f ", dpfu_ass_array[i]);
	  fprintf(parsedFile, "%.3f ", gcurve_ass_array[i]);
	  fprintf(parsedFile, "%.4f ", dpfu_gcurve_ass_array[i]);
	  fprintf(parsedFile, "%.1f ", LO_array[i]);
	  fprintf(parsedFile, "%s\n ", sourcetype_array[i]);
	}
      }
      valcount++;
    }
  }
  
  fputs("*\n", parsedFile);
  
  fputs("$STATS\n", parsedFile);

  fputs("*\n", parsedFile);

  fputs("$GAIN_CURVE\n", parsedFile);

  fputs("*\n", parsedFile);

  fputs("$TCAL\n", parsedFile);

  fputs("*\n", parsedFile);

  fputs("$LO\n", parsedFile);
  for (i=0; i<rxcount; i++) {
    if(LO2array[i] != BADVALUE) {
      fprintf(parsedFile, "%s %s %.1f %.1f\n", namearray[i], typearray[i], LO1array[i], LO2array[i]);
    } else {
      fprintf(parsedFile, "%s %s %.1f\n", namearray[i], typearray[i], LO1array[i]);
    }
  }
  fclose(onoffFile);
  fclose(parsedFile);
  printf("%s\n",parsedFileName);
  exit(0);
}


int min(int x, int y) { 
    if(x<y){ 
        return x; 
    } 
    else { 
        return y; 
    } 
} 
