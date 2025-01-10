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

uniform sampler2D gcolor;

in vec2 coord;

in vec4 tint;

void main() {
        sceneColor      = texture(gcolor, coord) * tint;
        sceneColor.rgb  = toLinear(sceneColor.rgb);

    compressSceneColor(sceneColor.rgb);
}