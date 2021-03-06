//
//  DisabilityTermInsurance.c
//  RK_C
//
//  Created by Nicolai Dahl on 05/02/12.
//  Copyright (c) 2012 ITU. All rights reserved.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../RK_Library.h"
#include "DisabilityTermInsurance.h"
#include <math.h>

static double *matrix[51];

static double row0[]  = {0.0714186989824431,    0.0000000000000000};
static double row1[]  = {0.0742705084048387,    0.0000000000000000};
static double row2[]  = {0.0772312485352858,    0.0000000000000000};
static double row3[]  = {0.0803007388769112,    0.0000000000000000};
static double row4[]  = {0.0834779380618836,    0.0000000000000000};
static double row5[]  = {0.0867607747788289,    0.0000000000000000};
static double row6[]  = {0.0901459511899878,    0.0000000000000000};
static double row7[]  = {0.0936287143026796,    0.0000000000000000};
static double row8[]  = {0.0972025899462083,    0.0000000000000000};
static double row9[]  = {0.1008590729874850,    0.0000000000000000};
static double row10[] = {0.1045872661636680,    0.0000000000000000};
static double row11[] = {0.1083734583544920,    0.0000000000000000};
static double row12[] = {0.1122006311731980,    0.0000000000000000};
static double row13[] = {0.1160478803013540,    0.0000000000000000};
static double row14[] = {0.1198897349010070,    0.0000000000000000};
static double row15[] = {0.1236953544561090,    0.0000000000000000};
static double row16[] = {0.1274275773038030,    0.0000000000000000};
static double row17[] = {0.1310417884996260,    0.0000000000000000};
static double row18[] = {0.1344845660310780,    0.0000000000000000};
static double row19[] = {0.1376920530492920,    0.0000000000000000};
static double row20[] = {0.1405879887686990,    0.0000000000000000};
static double row21[] = {0.1430813106541400,    0.0000000000000000};
static double row22[] = {0.1450632136041590,    0.0000000000000000};
static double row23[] = {0.1464035154086170,    0.0000000000000000};
static double row24[] = {0.1469461280481600,    0.0000000000000000};
static double row25[] = {0.1465033660147020,    0.0000000000000000};
static double row26[] = {0.1448487279175560,    0.0000000000000000};
static double row27[] = {0.1417076547118570,    0.0000000000000000};
static double row28[] = {0.1367455798907500,    0.0000000000000000};
static double row29[] = {0.1295523183539230,    0.0000000000000000};
static double row30[] = {0.1196214525705190,    0.0000000000000000};
static double row31[] = {0.1063228073533260,    0.0000000000000000};
static double row32[] = {0.0888652648692060,    0.0000000000000000};
static double row33[] = {0.0662459119488600,    0.0000000000000000};
static double row34[] = {0.0371795952968856,    0.0000000000000000};
static double row35[] = {0.0000000000000000,    0.0000000000000000};
static double row36[] = {0.0000000000000000,    0.0000000000000000};
static double row37[] = {0.0000000000000000,    0.0000000000000000};
static double row38[] = {0.0000000000000000,    0.0000000000000000};
static double row39[] = {0.0000000000000000,    0.0000000000000000};
static double row40[] = {0.0000000000000000,    0.0000000000000000};
static double row41[] = {0.0000000000000000,    0.0000000000000000};
static double row42[] = {0.0000000000000000,    0.0000000000000000};
static double row43[] = {0.0000000000000000,    0.0000000000000000};
static double row44[] = {0.0000000000000000,    0.0000000000000000};
static double row45[] = {0.0000000000000000,    0.0000000000000000};
static double row46[] = {0.0000000000000000,    0.0000000000000000};
static double row47[] = {0.0000000000000000,    0.0000000000000000};
static double row48[] = {0.0000000000000000,    0.0000000000000000};
static double row49[] = {0.0000000000000000,    0.0000000000000000};
static double row50[] = {0.0000000000000000,    0.0000000000000000};

/* tv */
double** tv_DisabilityTermInsurance() {

  matrix[0] = row0;
  matrix[1] = row1;
  matrix[2] = row2;
  matrix[3] = row3;
  matrix[4] = row4;
  matrix[5] = row5;
  matrix[6] = row6;
  matrix[7] = row7;
  matrix[8] = row8;
  matrix[9] = row9;
  matrix[10] = row10;
  matrix[11] = row11;
  matrix[12] = row12;
  matrix[13] = row13;
  matrix[14] = row14;
  matrix[15] = row15;
  matrix[16] = row16;
  matrix[17] = row17;
  matrix[18] = row18;
  matrix[19] = row19;
  matrix[20] = row20;
  matrix[21] = row21;
  matrix[22] = row22;
  matrix[23] = row23;
  matrix[24] = row24;
  matrix[25] = row25;
  matrix[26] = row26;
  matrix[27] = row27;
  matrix[28] = row28;
  matrix[29] = row29;
  matrix[30] = row30;
  matrix[31] = row31;
  matrix[32] = row32;
  matrix[33] = row33;
  matrix[34] = row34;
  matrix[35] = row35;
  matrix[36] = row36;
  matrix[37] = row37;
  matrix[38] = row38;
  matrix[39] = row39;
  matrix[40] = row40;
  matrix[41] = row41;
  matrix[42] = row42;
  matrix[43] = row43;
  matrix[44] = row44;
  matrix[45] = row45;
  matrix[46] = row46;
  matrix[47] = row47;
  matrix[48] = row48;
  matrix[49] = row49;
  matrix[50] = row50;

  return matrix;
}

static int n = 35;
static int bdisabled = 1;

static double b_0(double t) {
  return 0.0;
}

static double b_1(double t) {
  return 0.0; 
}

static double GM01(double t) {
  return 0.0006 + pow(10, 4.71609 - 10 + 0.06*(age + t));
}

static double GM02(double t) {
  return GM(t);
}

static double GM12(double t) {
  return GM(t);
}

static double mu_01(double t) {
  return GM01(t);
}

static double mu_02(double t) {
  return GM02(t);
}

static double mu_12(double t) {
  return GM12(t);
}

static double bj_00(double t) {
  return 0.0;
}

static double bj_01(double t) {
  return bdisabled * indicator(t > 0) * indicator(t < n);
}

static double bj_02(double t) {
  return 0.0;
}

static double bj_11(double t) {
  return 0.0;
}

static double bj_12(double t) {
  return 0.0;
}

void bj_ii_DisabilityTermInsurance(double t, double* result) {
  result[0] += bj_00(t); // 0.0
  result[1] += bj_11(t); // 0.0
}

void dy_DisabilityTermInsurance(double t, double* V,double* result)
{
  result[0] = r(t) * V[0] - b_0(t) - mu_01(t) * (V[1] - V[0] + bj_01(t)) - mu_02(t) * (0 - V[0] + bj_02(t));
  result[1] = r(t) * V[1] - b_1(t) - mu_12(t) * (0 - V[1] + bj_12(t)); 
}
