//
//  RK_Library.c
//  RK_C
//
//  Created by Nicolai Dahl on 31/01/12.
//  Copyright (c) 2012 ITU. All rights reserved.
//

#include <stdio.h>
#include "RK_Library.h"
#include <math.h>

float age = 30.0f;
float interestrate = 0.05f;
float bpension = 1.0f;
float pensiontime = 35.0f;

float GM(float t) {
    //printf("t: %.7f GM(t): %.7f\n",t,(0.0005f + powf(10.0f, 5.728f - 10.0f + 0.038f*(age + t))));
    return 0.0005f + powf(10.0f, 5.728f - 10.0f + 0.038f*(age + t));
    //return 0.5f;
}

// Interest
float r(float t) {
    return interestrate;
}

float indicator(bool b) {
    return b ? 1.0f : 0.0f;
}
