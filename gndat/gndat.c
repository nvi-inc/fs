#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/rxgain_ds.h"

#define STL(dest,source) min(sizeof((dest)),strlen((source))+1)

#define MAXRX MAX_RXGAIN
#define MAXDETECTORS MAX_ONOFF_DET
#define BADVALUE -6000000
#define MISSINGVALUE -7000000
#define BADSTRVALUE "X"
#define MAXLINE 1024
#define MAX_DET_STR 5

int min(int x, int y); 

int main(int argc, char *argv[])
{
  char onoffFileName[64], *cptr;
  char parsedFileName[64];
  char rxgFileName[20], controlFileDir[64];
  double azimuth, elevation, skyfreq, gainc, tsys, sefd, tcaljy, tcalk, calratio, tcal_ass;
  double flux_ass, tcalk_over_jy_ass, gcurve_ass, dpfu_gcurve_ass, LO;
  char onetime[22], time[22], source[11], dummy[31], detector[MAX_DET_STR], ifchan[2], polarization[2], sourcetype[2];
  char source_array[MAXDETECTORS][11], detector_array[MAXDETECTORS][MAX_DET_STR];
  char ifchan_array[MAXDETECTORS][2], polarization_array[MAXDETECTORS][2], sourcetype_array[MAXDETECTORS][2];
  char namearray[MAXRX][265], typearray[MAXRX][6];
  double azimuth_array[MAXDETECTORS], elevation_array[MAXDETECTORS], skyfreq_array[MAXDETECTORS];
  double gainc_array[MAXDETECTORS], tsys_array[MAXDETECTORS], sefd_array[MAXDETECTORS];
  double tcaljy_array[MAXDETECTORS], tcalk_array[MAXDETECTORS], calratio_array[MAXDETECTORS];
  double tcal_ass_array[MAXDETECTORS], flux_ass_array[MAXDETECTORS], dpfu_ass_array[MAXDETECTORS];
  double gcurve_ass_array[MAXDETECTORS], dpfu_gcurve_ass_array[MAXDETECTORS], LO_array[MAXDETECTORS];
  double trec_array[MAXDETECTORS], tatm_array[MAXDETECTORS], tspill_array[MAXDETECTORS], tau_array[MAXDETECTORS];
  double LO1array[MAXRX], LO2array[MAXRX], tau0_array[MAXDETECTORS], airmass_array[MAXDETECTORS];
  double tcal_log_array[MAXRX];
  double a,b,c,elev,am;
  int detcount, valcount, i, j, k, right, firstapr, firstval; 
  int rxcount, error, icount, LOcount, works, somethingelse;
  char name[32], type[10];
  double LO1, LO2;
  FILE *onoffFile;
  FILE *parsedFile;
  FILE *rxgFile;
  char line[MAXLINE];     /* line buffer for fgets() */
  struct rxgain_ds rxgain[MAXRX];
  char names[MAXRX][256];
  int *ierr;
  float ctemp,mbprs,rhumi,wspd,wdir;
  int gndat2;
  a=0.00125;
  b=0.00291;
  c=0.063;
  detcount=0;
  valcount=0;
  right=0;
  firstapr=1;
  firstval=1;
  rxcount=0;
  LOcount=0;
  somethingelse=1;
  gndat2=strcmp(argv[0],"gndat2")==0;
  strncpy(onoffFileName,argv[1],STL(onoffFileName,argv[1]));
  strncpy(parsedFileName,argv[2],STL(parsedFileName,argv[2]));
  strncpy(controlFileDir,argv[4],STL(controlFileDir,argv[4]));
  if(argc >= 4 &&  1!=sscanf(argv[3],"%d",&works)) {
    printf("Pid might be wrong. Please open the log file again.");
    exit(0);
  }
  
  if(argc >= 4)
    cptr=argv[3];
  else 
    cptr="";
  
  icount = get_rxgain_files(controlFileDir,rxgain,names,&ierr,cptr)-1;
  
  if(icount < 0)
    {
      if(icount==-1)
        printf("No rxg files found\n");
      exit(0);
    }

  onoffFile = fopen(onoffFileName, "r");
  if(onoffFile == NULL)
    {
      printf("Error opening file: %s", onoffFileName);
      exit(0);
    }
  
  parsedFile = fopen(parsedFileName, "w");
  if(parsedFile == NULL)
    {
      printf("Error opening file: %s", parsedFileName);
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
  fputs("Airmass\n", parsedFile);
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
  fputs("Trec\n", parsedFile);
  fputs("Tspill\n", parsedFile);
  fputs("Tsys-Tspill\n", parsedFile);
  /*fputs("Tau\n", parsedFile);*/
  /*fputs("Tau0\n", parsedFile);*/
  if(gndat2) {
    fputs("Temperature\n",parsedFile);
    fputs("Pressure\n",parsedFile);
    fputs("Humidity\n",parsedFile);
    fputs("Wind Speed\n",parsedFile);
    fputs("Wind Azimuth\n",parsedFile);
  }
  fputs("*\n", parsedFile);
  
  fputs("$DATA\n", parsedFile);

  if(gndat2) {
    ctemp=MISSINGVALUE;
    mbprs=MISSINGVALUE;
    rhumi=MISSINGVALUE;
    wspd=MISSINGVALUE;
    wdir=MISSINGVALUE;
  }

  while (fgets(line, MAXLINE, onoffFile) != NULL) {
    /*if(strstr(line,";onoff") != NULL) {
      for (i=0; i<=detcount; i++) {
	strcpy(detector_array[i],"NULL");
      }
      if((NULL == (cptr = strtok(line," \t\n")) || (1!=sscanf(cptr, "%20s", onetime)))) {
	strcpy(onetime,BADSTRVALUE);
      }
      detcount=0;
      }*/
    if(gndat2 && strncmp(line+20,"/wx/",4)==0) {
      printf(" line %s\n",line);
	if((NULL == (cptr = strtok(line+24," ,\n")) || (1!=sscanf(cptr, "%f", &ctemp)))) {
	  ctemp=MISSINGVALUE;
	}
	if((NULL == (cptr = strtok(NULL," ,\n")) || (1!=sscanf(cptr, "%f", &mbprs)))) {
	  mbprs=MISSINGVALUE;
	}
	if((NULL == (cptr = strtok(NULL," ,\n")) || (1!=sscanf(cptr, "%f", &rhumi)))) {
	  rhumi=MISSINGVALUE;
	}
	if((NULL == (cptr = strtok(NULL," ,\n")) || (1!=sscanf(cptr, "%f", &wspd)))) {
	  wspd=MISSINGVALUE;
	}
	if((NULL == (cptr = strtok(NULL," ,\n")) || (1!=sscanf(cptr, "%f", &wdir)))) {
	  wdir=MISSINGVALUE;
	}
    }
    if(strstr(line,"APR") != NULL) {
      if(firstapr==1 || somethingelse==1) {
	for (i=0; i<=detcount; i++) {
	  strcpy(detector_array[i],"NULL");
	}
	if((NULL == (cptr = strtok(line," \t\n")) || (1!=sscanf(cptr, "%20s", onetime)))) {
	  strcpy(onetime,BADSTRVALUE);
	}
	detcount=0;
	firstapr=0;
	firstval=1;
	somethingelse=0;
      } else {      
	if((NULL == (cptr = strtok(line," \t\n")) || (1!=sscanf(cptr, "%20s", time)))) {
	  strcpy(time,BADSTRVALUE);
	}
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
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%lf", &LO)) || LO < 0) {
	LO = BADVALUE;
      }
      if(NULL == (cptr = strtok(NULL," \t\n")) || (1!=sscanf(cptr, "%s", sourcetype))) {
	strcpy(sourcetype,BADSTRVALUE);
      }
      
      strncpy(detector_array[detcount],detector,min(MAX_DET_STR,strlen(detector))+1);
      skyfreq_array[detcount] = skyfreq;
      tcal_log_array[detcount] = tcal_ass;
      flux_ass_array[detcount] = flux_ass;
      dpfu_ass_array[detcount] = tcalk_over_jy_ass;
      gcurve_ass_array[detcount] = gcurve_ass;
      dpfu_gcurve_ass_array[detcount] = dpfu_gcurve_ass;
      LO_array[detcount] = LO;
      strncpy(sourcetype_array[detcount],sourcetype,STL(MAXDETECTORS,sourcetype));
      
      for (i=0; i<=icount; i++) {
	/*This allows "fuzzy" matching of LOs.*/
	if(((rxgain[i].type=='f') && \
	    ((LO>=(rxgain[i].lo[1] - rxgain[i].lo[1]/1000) && LO<=(rxgain[i].lo[1] + rxgain[i].lo[1]/1000)) || \
	     (LO>=(rxgain[i].lo[0] - rxgain[i].lo[0]/1000) && LO<=(rxgain[i].lo[0] + rxgain[i].lo[0]/1000)))) || \
	   ((rxgain[i].type=='r') && (LO<=rxgain[i].lo[1] && LO>=rxgain[i].lo[0]))) {
	  k=0;
	  for(j=0; j<=icount; j++) {
	    if(strcmp(namearray[j],names[i])==0) {
	      k=1;
	      break;
	    }
	  }
	  if(k==0) {
	    strncpy(namearray[LOcount],names[i],STL(namearray[LOcount],names[i]));
	    if(rxgain[i].type=='f')
	      strncpy(typearray[LOcount],"fixed",STL(typearray[LOcount],"fixed"));
	    if(rxgain[i].type=='r')
	      strncpy(typearray[LOcount],"range",STL(typearray[LOcount],"range"));
	    if(rxgain[i].lo[1]==-1) {
	      LO1array[LOcount]=rxgain[i].lo[0];
  	    } else { 
	      LO1array[LOcount]=rxgain[i].lo[0];
	      LO2array[LOcount]=rxgain[i].lo[1];
  	    } 
	    LOcount++;
  	    break;
  	  } 
	}
      }
      
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
      strncpy(source_array[valcount],source,min(MAXDETECTORS,strlen(source))+1);
      azimuth_array[valcount] = azimuth;
      elevation_array[valcount] = elevation;
      airmass_array[valcount] = 1/sin(3.1415927/180*elevation);
      strncpy(ifchan_array[valcount],ifchan,min(MAXDETECTORS,strlen(ifchan))+1);
      strncpy(polarization_array[valcount],polarization,min(MAXDETECTORS,strlen(polarization))+1);
      gainc_array[valcount] = gainc;
      tsys_array[valcount] = tsys;
      if(tsys == BADVALUE || (tsys-trec_array[valcount]-tspill_array[valcount])/tatm_array[valcount] >= 1) {
	tau_array[valcount] =  BADVALUE;
      } else {
	tau_array[valcount] = log(1/(1-(tsys-trec_array[valcount]-tspill_array[valcount])/tatm_array[valcount]));
      }
      sefd_array[valcount] = sefd;
      tcaljy_array[valcount] = tcaljy;
      
      for (i=0; i<=detcount; i++) {
	if(strcmp(detector,detector_array[i])==0) {
	  float fwhm,dpfu,gain,tcal,trec,tspill;
	  /*printf("%d %f %f\n",rxcount,LO_array[i],skyfreq_array[i]);*/
	  get_gain_par2(&rxgain,MAXRX,LO_array[i],skyfreq_array[i],1.0,elevation_array[valcount],polarization_array[valcount][0],&fwhm,&dpfu,&gain,&tcal,&trec,&tspill);
	  tcal_ass_array[i]=tcal;
	  tsys_array[valcount]=tsys_array[valcount]*tcal/tcal_log_array[valcount];
	  dpfu_ass_array[i]=dpfu;
	  gcurve_ass_array[i]=gain;
	  trec_array[i] = trec;
	  tspill_array[i] = tspill;
	  if(tcaljy_array[i]<=0 || tcal_ass_array[i]<=0) {
	    tcalk_array[i]=BADVALUE;
	    calratio_array[i]=BADVALUE;
	  } else {
	    tcalk_array[i]=dpfu*tcaljy_array[i]*gain;
	    calratio_array[i]=tcalk_array[i]/tcal_ass_array[i];
	  }
	  dpfu_gcurve_ass_array[i]=dpfu*gain;
	  
	  fprintf(parsedFile, "%s ", onetime);
	  fprintf(parsedFile, "%s ", source_array[valcount]);
	  fprintf(parsedFile, "%.1f ", azimuth_array[valcount]);
	  fprintf(parsedFile, "%.1f ", elevation_array[valcount]);
  	  fprintf(parsedFile, "%.2f ", airmass_array[valcount]);
	  fprintf(parsedFile, "%s ", detector_array[i]);
	  fprintf(parsedFile, "%s ", ifchan_array[valcount]);
	  fprintf(parsedFile, "%s ", polarization_array[valcount]);
	  fprintf(parsedFile, "%.1f ", skyfreq_array[i]);
	  fprintf(parsedFile, "%.4f ", gainc_array[valcount]);
	  fprintf(parsedFile, "%.2f ", tsys_array[valcount]);
	  fprintf(parsedFile, "%.1f ", sefd_array[valcount]);
	  fprintf(parsedFile, "%.3f ", tcaljy_array[valcount]);
	  fprintf(parsedFile, "%.3f ", tcalk_array[i]);
	  fprintf(parsedFile, "%.4f ", calratio_array[i]);
	  if(tcaljy_array[i]<=0) {
	    fprintf(parsedFile, "%.2f ", BADVALUE);
	  } else {
	    if(tcal_ass_array[i]/tcaljy_array[valcount]<0.01) {
	      fprintf(parsedFile, "%.6f ", tcal_ass_array[i]/tcaljy_array[valcount]);
	    } else {
	      fprintf(parsedFile, "%.5f ", tcal_ass_array[i]/tcaljy_array[valcount]);
	    } 
	  }
	  fprintf(parsedFile, "%.3f ", tcal_ass_array[i]);
	  fprintf(parsedFile, "%.1f ", flux_ass_array[i]);
	  fprintf(parsedFile, "%.4f ", dpfu_ass_array[i]);
	  fprintf(parsedFile, "%.3f ", gcurve_ass_array[i]);
	  fprintf(parsedFile, "%.4f ", dpfu_gcurve_ass_array[i]);
	  fprintf(parsedFile, "%.1f ", LO_array[i]);
	  fprintf(parsedFile, "%s ", sourcetype_array[i]);
	  fprintf(parsedFile, "%.1f ", trec_array[i]);
	  fprintf(parsedFile, "%.1f ", tspill_array[i]);
	  fprintf(parsedFile, "%.2f ", tsys_array[valcount]-tspill_array[i]);
	  /*fprintf(parsedFile, "%.4f\n", tau_array[valcount]);*/
	  if(gndat2) {
	    fprintf(parsedFile, "%f ", ctemp);
	    fprintf(parsedFile, "%f ", mbprs);
	    fprintf(parsedFile, "%f ", rhumi);
	    fprintf(parsedFile, "%f ", wspd);
	    fprintf(parsedFile, "%f ", wdir);
	  }
	  fprintf(parsedFile,"\n");
	}
      }
      valcount++;
    }
    if(strstr(line,"APR") == NULL && strstr(line,"VAL") == NULL) {
      somethingelse=1;
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

  for (i=0; i<LOcount; i++) {
    if(LO2array[i] > 0) {
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





















