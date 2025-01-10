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

/*DRAWBUFFERS:0*/
layout(location = 0) out vec3 sceneLDR;

#include "/lib/head.glsl"

#define INFO 0  //[0]

/* ------ color grading related settings ------ */
//#define doColorgrading

#define vibranceInt 1.00       //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define saturationInt 1.00     //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define gammaCurve 1.00        //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define brightnessInt 0.00     //[-0.50 -0.45 -0.40 -0.35 -0.30 -0.25 -0.20 -0.15 -0.10 -0.05 0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.5]
#define constrastInt 1.00      //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

#define colorlumR 1.00         //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define colorlumG 1.00         //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]
#define colorlumB 1.00         //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00 1.05 1.10 1.15 1.20 1.25 1.30 1.35 1.40 1.45 1.50 1.55 1.60 1.65 1.70 1.75 1.80 1.85 1.90 1.95 2.00]

#define vignetteEnabled
#define vignetteStart 0.15     //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define vignetteEnd 0.85       //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define vignetteIntensity 0.50 //[0.00 0.05 0.10 0.15 0.20 0.25 0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90 0.95 1.00]
#define vignetteExponent 1.50  //[0.50 0.75 1.0 1.25 1.50 1.75 2.00 2.25 2.50 2.75 3.00 3.25 3.50 3.75 4.00 4.25 4.50 4.75 5.00]

in vec2 coord;

uniform sampler2D colortex0;
uniform sampler2D colortex3;

uniform sampler2D noisetex;

uniform float aspectRatio;
uniform float exposureLevel;
uniform float frameTimeCounter;
uniform int isEyeInWater;

uniform ivec2 eyeBrightnessSmooth;

uniform vec4 daytime;

vec3 bloomExpand(vec3 x) {
        x *= compressionCoeff;
    return x * x * x * x;
}

vec3 getBloom(vec2 coord) {
    vec3 blur1 = bloomExpand(texture(colortex3, coord.xy / pow(2.0,2.0) + vec2(0.0,0.0)).rgb);
    vec3 blur2 = bloomExpand(texture(colortex3, coord.xy / pow(2.0,3.0) + vec2(0.3,0.0)).rgb)*0.95;
    vec3 blur3 = bloomExpand(texture(colortex3, coord.xy / pow(2.0,4.0) + vec2(0.0,0.3)).rgb)*0.9;
    vec3 blur4 = bloomExpand(texture(colortex3, coord.xy / pow(2.0,5.0) + vec2(0.1,0.3)).rgb)*0.85;
    vec3 blur5 = bloomExpand(texture(colortex3, coord.xy / pow(2.0,6.0) + vec2(0.2,0.3)).rgb)*0.8;
    vec3 blur6 = bloomExpand(texture(colortex3, coord.xy / pow(2.0,7.0) + vec2(0.3,0.3)).rgb)*0.75;
    vec3 blur7 = bloomExpand(texture(colortex3, coord.xy / pow(2.0,8.0) + vec2(0.4,0.3)).rgb)*0.7;
    
    vec3 blur = (blur1 + blur2 + blur3 + blur4 + blur5 + blur6 + blur7) / 7.0;
    float blurLuma = getLuma(blur);
        blur *= 1.0 + sqr(max0(blurLuma - 1.0)) * pi;

    return blur;
}

float calculateLegacyExposure() {
    vec2 levels     = saturate(vec2(eyeBrightnessSmooth) / 240.0);

    float outdoorLevel = 0.9 * daytime.x + 1.0 * daytime.y + 0.9 * daytime.z + 0.5 * daytime.w;
        outdoorLevel   = mix(0.5, outdoorLevel, levels.y);
    float indoorLevel  =  mix(0.5, 1.0, levels.x);

    return 1.0 / max(outdoorLevel, indoorLevel);
}

const mat3 XYZ_sRGB = mat3(
	 3.2409699419, -1.5373831776, -0.4986107603,
	-0.9692436363,  1.8759675015,  0.0415550574,
	 0.0556300797, -0.2039769589,  1.0569715142
);
const mat3 sRGB_XYZ = mat3(
	0.4124564, 0.3575761, 0.1804375,
	0.2126729, 0.7151522, 0.0721750,
	0.0193339, 0.1191920, 0.9503041
);

const mat3 XYZ_P3D65 = mat3(
    2.4933963, -0.9313459, -0.4026945,
    -0.8294868,  1.7626597,  0.0236246,
    0.0358507, -0.0761827,  0.9570140
);
const mat3 XYZ_REC2020 = mat3(
	 1.7166511880, -0.3556707838, -0.2533662814,
	-0.6666843518,  1.6164812366,  0.0157685458,
	 0.0176398574, -0.0427706133,  0.9421031212
);
// https://en.wikipedia.org/wiki/Adobe_RGB_color_space
const mat3 XYZ_AdobeRGB = mat3(
      2.04158790381075,  -0.56500697427886,  -0.34473135077833,
     -0.96924363628088,   1.87596750150772, 0.0415550574071756,
    0.0134442806320311, -0.118362392231018,   1.01517499439121
);

// Bradford chromatic adaptation from standard D65 to DCI Cinema White
const mat3 D65_DCI = mat3(
    1.02449672775258,     0.0151635410224164, 0.0196885223342068,
    0.0256121933371582,   0.972586305624413,  0.00471635229242733,
    0.00638423065008769, -0.0122680827367302, 1.14794244517368
);

const mat3 sRGB_to_P3DCI = ((sRGB_XYZ) * XYZ_P3D65) * D65_DCI;
const mat3 sRGB_to_P3D65 = sRGB_XYZ * XYZ_P3D65;
const mat3 sRGB_to_REC2020 = sRGB_XYZ * XYZ_REC2020;
const mat3 sRGB_to_AdobeRGB = sRGB_XYZ * XYZ_AdobeRGB;

#if (defined COLOR_SPACE_SRGB || defined COLOR_SPACE_DCI_P3 || defined COLOR_SPACE_DISPLAY_P3 || defined COLOR_SPACE_REC2020 || defined COLOR_SPACE_ADOBE_RGB)

uniform int currentColorSpace;

// https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics
vec3 EOTF_Curve(vec3 LinearCV, const float LinearFactor, const float Exponent, const float Alpha, const float Beta) {
    return mix(LinearCV * LinearFactor, clamp(Alpha * pow(LinearCV, vec3(Exponent)) - (Alpha - 1.0), 0.0, 1.0), step(Beta, LinearCV));
}

// https://en.wikipedia.org/wiki/SRGB#Transfer_function_(%22gamma%22)
vec3 EOTF_IEC61966(vec3 LinearCV) {
    return EOTF_Curve(LinearCV, 12.92, 1.0 / 2.4, 1.055, 0.0031308);;
    //return mix(LinearCV * 12.92, clamp(pow(LinearCV, vec3(1.0/2.4)) * 1.055 - 0.055, 0.0, 1.0), step(0.0031308, LinearCV));
}
// https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics
vec3 EOTF_BT709(vec3 LinearCV) {
    return EOTF_Curve(LinearCV, 4.5, 0.45, 1.099, 0.018);
    //return mix(LinearCV * 4.5, clamp(pow(LinearCV, vec3(0.45)) * 1.099 - 0.099, 0.0, 1.0), step(0.018, LinearCV));
}
// https://en.wikipedia.org/wiki/DCI-P3
vec3 EOTF_P3DCI(vec3 LinearCV) {
    return pow(LinearCV, vec3(1.0 / 2.6));
}
// https://en.wikipedia.org/wiki/Adobe_RGB_color_space
vec3 EOTF_Adobe(vec3 LinearCV) {
    return pow(LinearCV, vec3(1.0 / 2.2));
}

vec3 OutputGamutTransform(vec3 LinearCV) {
    switch(currentColorSpace) {
        case COLOR_SPACE_SRGB:
            return EOTF_IEC61966(LinearCV);

        case COLOR_SPACE_DCI_P3:
            LinearCV = LinearCV * sRGB_to_P3DCI;
            return EOTF_P3DCI(LinearCV);

        case COLOR_SPACE_DISPLAY_P3:
            LinearCV = LinearCV * sRGB_to_P3D65;
            return EOTF_IEC61966(LinearCV);

        case COLOR_SPACE_REC2020:
            LinearCV = LinearCV * sRGB_to_REC2020;
            return EOTF_BT709(LinearCV);

        case COLOR_SPACE_ADOBE_RGB:
            LinearCV = LinearCV * sRGB_to_AdobeRGB;
            return EOTF_Adobe(LinearCV);
    }
    // Fall back to sRGB if unknown
    return EOTF_IEC61966(LinearCV);
}

#else

#define VIEWPORT_GAMUT 0    //[0 1 2] 0: sRGB, 1: P3D65, 2: Display P3

vec3 OutputGamutTransform(vec3 Linear) {
#if VIEWPORT_GAMUT == 1
    vec3 P3 = Linear * sRGB_P3D65;
    //return LinearToSRGB(P3);
    return pow(P3, vec3(1.0 / 2.6));
#elif VIEWPORT_GAMUT == 2
    vec3 P3 = Linear * sRGB_P3D65;
    return linearToSRGB(P3);
    //return pow(P3, vec3(1.0 / 2.2));
#else
    return linearToSRGB(Linear);
#endif
}

#endif

vec3 tonemapReinhard(vec3 hdr) {
    float luma      = getLuma(hdr);

    const float coeff   = 0.9;
    const float white   = 8.0;

    vec4 hdrWhite   = vec4(hdr, white);

    vec4 col        = hdrWhite / (hdrWhite + coeff);
        col         = mix(hdrWhite / (vec4(vec3(luma), white) + coeff), col, col);

    return OutputGamutTransform(col.rgb / col.a);
}
vec3 tonemapHejlBurgess(vec3 hdr) {
    hdr        *= 0.75;
    vec3 x      = max(hdr, 0.0);    
        x = (x * (6.2 * x + 0.5)) * rcp(x * (6.2 * x + 1.7) + 0.06);
    return OutputGamutTransform(toLinear(x));
}

#define HASHSCALE3 vec3(.1031, .1030, .0973)
vec3 hash33(vec3 p3) {
	p3      = fract(p3 * HASHSCALE3);
    p3     += dot(p3, p3.yxz + 19.19);
    return fract((p3.xxy + p3.yxx) * p3.zyx);
}

/* ------ color grading utilities ------ */

vec3 rgbLuma(vec3 x) {
    return x * vec3(colorlumR, colorlumG, colorlumB);
}

vec3 applyGammaCurve(vec3 x) {
    return pow(x, vec3(gammaCurve));
}

vec3 vibranceSaturation(vec3 color) {
    float lum   = dot(color, lumacoeffRec709);
    float mn    = min(min(color.r, color.g), color.b);
    float mx    = max(max(color.r, color.g), color.b);
    float sat   = (1.0 - saturate(mx-mn)) * saturate(1.0-mx) * lum * 5.0;
    vec3 light  = vec3((mn + mx) / 2.0);

    color   = mix(color, mix(light, color, vibranceInt), saturate(sat));

    color   = mix(color, light, saturate(1.0-light) * (1.0-vibranceInt) / 2.0 * abs(vibranceInt));

    color   = mix(vec3(lum), color, saturationInt);

    return color;
}

vec3 brightnessContrast(vec3 color) {
    return (color - 0.5) * constrastInt + 0.5 + brightnessInt;
}

vec3 vignette(vec3 color) {
    float fade      = length(coord*2.0-1.0);
        fade        = linStep(abs(fade) * 0.5, vignetteStart, vignetteEnd);
        fade        = 1.0 - pow(fade, vignetteExponent) * vignetteIntensity;

    return color * fade;
}

vec2 rotatePos(vec2 pos, const float angle) {
    return vec2(cos(angle)*pos.x + sin(angle)*pos.y, 
                cos(angle)*pos.y - sin(angle)*pos.x);
}

void main() {
    vec2 refractUV  = coord;
    if (isEyeInWater == 1) {
        vec2 noiseUV    = coord * vec2(1.0, aspectRatio);
        vec2 refractNoise = sincos(texture(noisetex, noiseUV * 0.06 + frameTimeCounter * 0.01).x);
            noiseUV     = rotatePos(noiseUV, euler);
            refractNoise += sincos(texture(noisetex, noiseUV * 0.1 - frameTimeCounter * 0.01).x) * 0.5;
            noiseUV     = rotatePos(noiseUV, euler);
            refractNoise += sincos(texture(noisetex, noiseUV * 0.16 - frameTimeCounter * 0.01).x) * 0.25;

            refractUV    += refractNoise * 0.05 * vec2(1.0, 1.0 / aspectRatio);
            refractUV     = mix(coord, refractUV, exp(-abs(coord * 2.0 - 1.0)));
    }

    vec3 sceneHDR   = texture(colortex0, refractUV).rgb;
    decompressSceneColor(sceneHDR);

    #ifdef bloomEnabled
        vec3 bloom      = getBloom(refractUV);

        #if DIM == -1
            sceneHDR    = mix(sceneHDR, bloom, saturate(0.15 * bloomIntensity));
        #else
            sceneHDR    = mix(sceneHDR, bloom, 0.042 * bloomIntensity);
        #endif
    #endif
    
        sceneHDR   += hash33(vec3(gl_FragCoord.xy, frameTimeCounter / euler)) * 0.003 * filmGrainStrength;

        sceneHDR   *= exposureLevel;

    #ifdef doColorgrading
        sceneHDR    = vibranceSaturation(sceneHDR);
        sceneHDR    = rgbLuma(sceneHDR);
    #endif

    #ifdef vignetteEnabled
        sceneHDR    = vignette(sceneHDR);
    #endif

        sceneLDR   = tonemapHejlBurgess(sceneHDR);

    #if DEBUG_VIEW==5
        sceneLDR    = sqrt(sceneHDR);
    #endif

    #ifdef doColorgrading
        sceneLDR    = brightnessContrast(sceneLDR);
        sceneLDR    = applyGammaCurve(sceneLDR);
    #endif
}