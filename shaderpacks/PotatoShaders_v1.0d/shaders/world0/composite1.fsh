#version 400 compatibility

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
layout(location = 0) out vec3 sceneColor;

#include "/lib/head.glsl"

const int noiseTextureResolution = 256;

in vec2 coord;

flat in mat4x3 colorPalette;

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D colortex3;
uniform sampler2D colortex4;

uniform sampler2D depthtex0;
uniform sampler2D depthtex1;

uniform sampler2D noisetex;

uniform int frameCounter;
uniform int isEyeInWater;

uniform float aspectRatio;
uniform float far, near;

uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;

uniform vec2 viewSize, pixelSize;
uniform vec2 taaOffset;

uniform vec3 sunDirView;
uniform vec3 moonDirView;
uniform vec3 upDirView;

uniform vec4 daytime;

uniform mat4 gbufferModelView, gbufferModelViewInverse;
uniform mat4 gbufferProjection, gbufferProjectionInverse;

#define FUTIL_LINDEPTH
#include "/lib/fUtil.glsl"
#include "/lib/util/transforms.glsl"

#include "/lib/atmos/skyGradient.glsl"

#include "/lib/atmos/fog.glsl"


/* ------ refraction ------ */

vec3 refract2(vec3 I, vec3 N, vec3 NF, float eta) {     //from spectrum by zombye
    float NoI = dot(N, I);
    float k = 1.0 - eta * eta * (1.0 - NoI * NoI);
    if (k < 0.0) {
        return vec3(0.0); // Total Internal Reflection
    } else {
        float sqrtk = sqrt(k);
        vec3 R = (eta * dot(NF, I) + sqrtk) * NF - (eta * NoI + sqrtk) * N;
        return normalize(R * sqrt(abs(NoI)) + eta * I);
    }
}

const float gauss9w[9] = float[9] (
     0.0779, 0.12325, 0.0779,
    0.12325, 0.1954,  0.12225,
     0.0779, 0.12325, 0.0779
);

const vec2 gauss9o[9] = vec2[9] (
    vec2(1.0, 1.0), vec2(0.0, 1.0), vec2(-1.0, 1.0),
    vec2(1.0, 0.0), vec2(0.0, 0.0), vec2(-1.0, 0.0),
    vec2(1.0, -1.0), vec2(0.0, -1.0), vec2(-1.0, -1.0)
);

vec3 gauss9DepthAware(sampler2D tex, sampler2D depth, float compareDepth, float sigma, vec2 coord) {
    vec3 col        = vec3(0.0);
    vec3 baseCol    = texture(tex, coord).rgb;

    for (int i = 0; i<9; i++) {
        vec2 bcoord = coord + gauss9o[i] * sigma;
        float depth = texture(depth, bcoord).x;

        if (depth > compareDepth) col += texture(tex, bcoord).rgb * gauss9w[i];

        else col += baseCol * gauss9w[i];
    }

    decompressSceneColor(col);
    
    return col;
}

void main() {
    sceneColor  = texture(colortex0, coord).rgb;

    decompressSceneColor(sceneColor);

    float sceneDepth0   = stex(depthtex0).x;
    vec3 viewPos0       = screenToViewSpace(vec3(coord, sceneDepth0));
    vec3 scenePos0      = viewToSceneSpace(viewPos0);

    float sceneDepth1   = stex(depthtex1).x;
    vec3 viewPos1       = screenToViewSpace(vec3(coord, sceneDepth1));
    vec3 scenePos1      = viewToSceneSpace(viewPos1);

    vec4 transparency   = stex(colortex3);
        decompressSceneColor(transparency.rgb);

    vec4 auxData        = texture(colortex2, coord);
    vec3 sceneNormal    = decodeNormal(auxData.xy);
    vec3 viewNormal     = mat3(gbufferModelView) * sceneNormal;

    vec4 auxData2       = texture(colortex4, coord);
    vec3 sceneNormal0   = decodeNormal(auxData2.xy);
    vec3 viewNormal0    = mat3(gbufferModelView) * sceneNormal0;

    int matID_Transparent = int(auxData2.z * 65535.0);

    bool cloud          = int(auxData.z * 65535.0) == 200;
    bool cloud2         = int(auxData2.z * 65535.0) == 200;

    bool water          = matID_Transparent == 102;

    vec2 refractCoord   = coord;

    float cave      = sqr(saturate(float(eyeBrightnessSmooth.y) / 240.0));

    #ifdef refractionEnabled
    if (water){
        vec3 flatNormal     = normalize(cross(dFdx(scenePos0), dFdy(scenePos0)));

        if (clampDIR(flatNormal) != flatNormal) flatNormal = sceneNormal;
        flatNormal      = clampDIR(flatNormal);

        vec3 flatViewNormal = normalize(mat3(gbufferModelView) * flatNormal);

        vec3 normalCorrected = dot(viewNormal0, normalize(viewPos1)) > 0.0 ? -viewNormal0 : viewNormal0;

        vec3 refractedDir   = refract2(normalize(viewPos1), normalCorrected, flatViewNormal, rcp(1.33));

        float refractedDist = distance(viewPos0, viewPos1);

        vec3 refractedPos   = viewPos1 + refractedDir * refractedDist;

        vec3 screenPos      = viewToScreenSpace(refractedPos);

        float distToEdge    = maxOf(abs(screenPos.xy * 2.0 - 1.0));
            distToEdge      = sqr(sstep(distToEdge, 0.7, 1.0));

        screenPos.xy    = mix(screenPos.xy, coord, distToEdge);

        float sceneDepth    = texture(depthtex1, screenPos.xy).x;

        if (sceneDepth > sceneDepth0) {
            sceneDepth1 = sceneDepth;
            viewPos1    = screenToViewSpace(vec3(screenPos.xy, sceneDepth1));
            scenePos1   = viewToSceneSpace(viewPos1);

            sceneColor.rgb  = texture(colortex0, screenPos.xy).rgb;
            decompressSceneColor(sceneColor.rgb);

            refractCoord = screenPos.xy;
        }
    }
    #endif

    #ifdef transparencyBlurEnabled
    if (sceneDepth1 > sceneDepth0 && !cloud2) sceneColor.rgb  = gauss9DepthAware(colortex0, depthtex1, sceneDepth0, 0.0014, refractCoord);
    #endif

    if (cloud2) transparency.rgb *= 1.0 / 0.85;

    if (!(cloud && sceneDepth1 <= sceneDepth0)) sceneColor.rgb = sceneColor.rgb * finv(transparency.a) + transparency.rgb;

        vec3 viewPos        = screenToViewSpace(vec3(coord, sceneDepth0));
        vec3 scenePos       = viewToSceneSpace(viewPos);

    if (landMask(sceneDepth0)) {
        vec3 sceneNormal    = decodeNormal(auxData.xy);
        
        if ((isEyeInWater != 1) && !((cloud || cloud2) && (sceneDepth0 == sceneDepth1))) {
            sceneColor  = getFog(sceneColor, scenePos, -normalize(viewPos));
        }
    }

    if (isEyeInWater == 1) sceneColor = getWaterFog(sceneColor, length(scenePos), -normalize(viewPos), cave);

    if (cloud2) sceneColor  = getCloudFog(sceneColor, scenePos, -normalize(viewPos));

    if (isEyeInWater == 2) {
        sceneColor  = mix(sceneColor, vec3(1.0, 0.26, 0.04), 1.0 - exp(-length(scenePos)));
    }

    compressSceneColor(sceneColor);
}