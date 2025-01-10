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

/*DRAWBUFFERS:3*/
layout(location = 0) out vec3 bloomData;

#include "/lib/head.glsl"

in vec2 coord;

uniform sampler2D colortex0;

#ifdef bloom
const bool colortex0MipmapEnabled = true;
#endif

uniform float aspectRatio;
uniform float viewWidth, viewHeight;

uniform vec2 viewSize;

vec3 bloomBuffers(float mip, vec2 offset){
    float pxWidth       = 1.0/viewWidth;

	vec3 bufferTex 	= vec3(0.0);
	vec3 temp 		= vec3(0.0);
	float scale 	= pow(2.0, mip);
	vec2 bCoord 	= (coord-offset)*scale;
	float padding 	= 0.005*scale;

	if (bCoord.x>-padding && bCoord.y>-padding && bCoord.x<1.0+padding && bCoord.y<1.0+padding) {
		for (int i=0;  i<7; i++) {
			for (int j=0; j<7; j++) {
				float wg 	= clamp(1.0-length(vec2(i-3,j-3))*0.28, 0.0, 1.0);
					wg 		= pow(wg, 2.0)*20;
				vec2 tCoord = (coord-offset+vec2(i-3, j-3)*pxWidth*vec2(1.0, aspectRatio))*scale;
				if (wg>0) {
					temp 	= (texture(colortex0, tCoord).rgb);

                    decompressSceneColor(temp);

                    temp   *= wg;

					bufferTex  += max(temp, 0.0);
				}
			}
		}
	bufferTex /=49;
	}
return pow(bufferTex, vec3(0.2));
}

vec3 makeBloomBuffer() {
    vec3 blur = vec3(0.0);
        blur += bloomBuffers(2, vec2(0,0));
        blur += bloomBuffers(3, vec2(0.3,0));
        blur += bloomBuffers(4, vec2(0,0.3));
        blur += bloomBuffers(5, vec2(0.1,0.3));
        blur += bloomBuffers(6, vec2(0.2,0.3));
        blur += bloomBuffers(7, vec2(0.3,0.3));
        blur += bloomBuffers(8, vec2(0.4,0.3));
        blur += bloomBuffers(9, vec2(0.5,0.3));
    return blur;
}

void main() {
    #ifdef bloomEnabled
    bloomData = makeBloomBuffer() / 4.0;
    #else
    bloomData = vec3(0.0);
    #endif
}