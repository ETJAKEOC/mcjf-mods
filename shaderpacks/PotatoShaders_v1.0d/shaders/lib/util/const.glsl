/*
====================================================================================================

    Copyright (C) 2020 RRe36

    All Rights Reserved unless otherwise explicitly stated.


    By downloading this you have agreed to the license and terms of use.
    These can be found inside the included license-file
    or here: https://rre36.com/copyright-license

    Violating these terms may be penalized with actions according to the Digital Millennium
    Copyright Act (DMCA), the Information Society Directive and/or similar laws
    depending on your country.

====================================================================================================
*/

const vec3 lumacoeffRec709 = vec3(0.2125, 0.7154, 0.0721);

const float pi      = radians(180.0);
const float sqrPi   = pi * pi;
const float halfPi  = pi / 2.0;
const float rpi     = 1.0 / pi;
const float pi4     = pi * 4.0;
const float tau     = radians(360.0);
const float phi     = sqrt(5.0) * 0.5 + 0.5;
const float goldenAngle = tau / phi / pi;
const float rLog2   = 1.0/log(2.0);
const float rLog10  = 1.0 / log(10.0);
const float sqrt2   = sqrt(2.0);
const float sqrt3   = sqrt(3.0);
const float euler   = 2.718281828459045;                    // euler's number
const float rho     = 1.32471795724474602596090885447809;   // plastic constant

const float sunPathRotation     = -15.0;    //[-90.0 -80.0 -70.0 -60.0 -50.0 -40.0 -35.0 -30.0 -25.0 -20.0 -15.0 -10.0 -5.0 0.0 5.0 10.0 15.0 20.0 25.0 30.0 35.0 40.0 50.0 60.0 70.0 80.0 90.0]

const float wetnessHalflife = 140.0;
const float drynessHalflife = 70.0;
const float eyeBrightnessHalflife = 5.0;