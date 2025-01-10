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

void main() {
    sceneColor  = texture(colortex0, coord).rgb;

    decompressSceneColor(sceneColor);

    float sceneDepth0   = stex(depthtex0).x;
    vec3 viewPos0       = screenToViewSpace(vec3(coord, sceneDepth0));
    vec3 scenePos0      = viewToSceneSpace(viewPos0);

    float sceneDepth1   = stex(depthtex1).x;
    vec3 viewPos1       = screenToViewSpace(vec3(coord, sceneDepth1));
    vec3 scenePos1      = viewToSceneSpace(viewPos1);

    vec4 auxData        = texture(colortex2, coord);

    vec4 auxData2       = texture(colortex4, coord);

    int matID_Transparent = int(auxData2.z * 65535.0);

    bool water          = matID_Transparent == 102;

    float cave      = sqr(saturate(float(eyeBrightnessSmooth.y) / 240.0));

    if (water && isEyeInWater == 0) sceneColor = getWaterFog(sceneColor, distance(scenePos0, scenePos1), -normalize(viewPos0), cave);

    compressSceneColor(sceneColor);
}