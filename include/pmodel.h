/* pmodel.h
 *
 * pointing model data structure definition file
 */

#define MAX_MODEL_PARAM 20
 
  struct pmdl {
  double pcof[MAX_MODEL_PARAM];
  int ipar[MAX_MODEL_PARAM];
  double phi;
  int imdl;
  int t[6];
  };
