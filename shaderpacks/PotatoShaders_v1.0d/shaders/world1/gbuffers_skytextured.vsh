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

#include "/lib/head.glsl"

out vec2 coord;

out vec4 tint;

uniform vec2 taaOffset;

uniform vec4 daytime;

void main() {
    vec4 pos    = gl_Vertex;
        pos     = viewMAD(gl_ModelViewMatrix, pos.xyz).xyzz;

        pos     = pos.xyzz * diag4(gl_ProjectionMatrix) + vec4(0.0, 0.0, gl_ProjectionMatrix[3].z, 0.0);

    #ifdef taaEnabled
        pos.xy += taaOffset*pos.w;
    #endif
        
    gl_Position = pos;
	
	tint        = gl_Color;
	tint.rgb 	= pow(tint.rgb, vec3(2.2));
	tint.rgb   *= 1.0 + daytime.y * 2.5;
	
	coord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	gl_FogFragCoord = gl_Position.z;
}