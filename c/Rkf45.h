#ifndef Rkf45_h
#define Rkf45_h

extern int neqn;
extern int start_year;
extern int end_year;
// dy
// bj_ii
extern double relerr;
extern double abserr;
extern double* end_year_y; 

double** estimate();
void construct(int n);

#endif
