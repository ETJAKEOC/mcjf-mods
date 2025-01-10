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
layout(location = 0) out vec4 sceneColor;

#include "/lib/head.glsl"

flat in int star;

in vec3 viewPos;

in vec4 tint;

flat in mat4x3 colorPalette;

uniform vec3 sunDirView;
uniform vec3 moonDirView;
uniform vec3 upDirView;

uniform vec4 daytime;

#include "/lib/atmos/skyGradient.glsl"

void main() {
    sceneColor      = tint;
    if (star == 0) sceneColor.a = 1.0;
    sceneColor.rgb  = getSky(-normalize(viewPos), colorPalette[3], colorPalette[2], colorPalette[0], vec3(star));
    compressSceneColor(sceneColor.rgb);
    //sceneColor.a    = 1.0;
}