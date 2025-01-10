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


float rcp(float x) {
    return crcp(x);
}
vec2 rcp(vec2 x) {
    return crcp(x);
}
vec3 rcp(vec3 x) {
    return crcp(x);
}

float sqr(float x) {
    return x*x;
}
float cube(float x) {
    return sqr(x)*x;
}
float pow4(float x) {
    return sqr(x)*sqr(x);
}
float pow5(float x) {
    return pow4(x)*x;
}
float pow6(float x) {
    return pow5(x)*x;
}
float pow8(float x) {
    return pow4(x)*pow4(x);
}

float log10(float x) {
    return log(x) * rLog10;
}
vec2 log10(vec2 x) {
    return log(x) * rLog10;
}
vec3 log10(vec3 x) {
    return log(x) * rLog10;
}

float cubeSmooth(float x) {
    return icubeSmooth(x);
}
vec2 cubeSmooth(vec2 x) {
    return icubeSmooth(x);
}

float flength(vec2 x) {
    return sqrt(dot(x, x));
}
float flength(vec3 x) {
    return sqrt(dot(x, x));
}

float avgOf(vec2 a)             { return (a.x + a.y) * 0.5; }
float avgOf(float a, float b)   { return (a + b) * 0.5; }
float avgOf(vec3 a)             { return (a.x + a.y + a.z) * rcp(3.0); }
float avgOf(float a, float b, float c) { return (a + b + c) * rcp(3.0); }
float avgOf(vec4 a)             { return (a.x + a.y + a.z + a.w) * rcp(4.0); }

float minOf(vec2 a)         { return min(a.x, a.y); }
float minOf(vec3 a)         { return min(a.x, min(a.y, a.z)); }
float minOf(float a, float b, float c) { return min(a, min(b, c)); }

float maxOf(vec2 a)         { return max(a.x, a.y); }
float maxOf(vec3 a)         { return max(a.x, max(a.y, a.z)); }
float maxOf(float a, float b, float c) { return max(a, max(b, c)); }

float selfDot3(vec3 x) {
    return dot(x, x);
}

vec2 sqr(vec2 x) {
    return x*x;
}

vec3 sqr(vec3 x) {
    return x*x;
}

float saturate(in float x) {
    return csaturate(x);
}

vec2 saturate(in vec2 x) {
    return csaturate(x);
}

vec3 saturate(in vec3 x) {
    return csaturate(x);
}

vec4 saturate(in vec4 x) {
    return csaturate(x);
}

float linStep(float x, float low, float high) {
    float t = saturate((x-low)/(high-low));
    return t;
}

vec3 linStep(vec3 x, float low, float high) {
    vec3 t = saturate((x-low)/(high-low));
    return t;
}

float thresholdStep(float x, float low) {
    if (x < low) return 0.0;

    float blend = linStep(x, low, low + low * 0.5);
    return x * blend;
}

float getLuma(vec3 x) {
    return dot(x, lumacoeffRec709);
}

vec3 colorSaturation(vec3 x, const float y) {
    return mix(vec3(getLuma(x)), x, y);
}

vec2 sincos(float x)        { return vec2(sin(x), cos(x)); }