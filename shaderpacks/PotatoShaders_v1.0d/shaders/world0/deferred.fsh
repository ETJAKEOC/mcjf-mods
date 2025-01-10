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

/*DRAWBUFFERS:03*/
layout(location = 0) out vec3 sceneColor;
layout(location = 1) out vec4 transparency;

#include "/lib/head.glsl"

const int noiseTextureResolution = 256;

in vec2 coord;

flat in mat4x3 colorPalette;

uniform sampler2D colortex0;
uniform sampler2D colortex2;
uniform sampler2D depthtex1;

uniform sampler2D noisetex;

uniform int frameCounter;

uniform float aspectRatio;
uniform float far, near;

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
#include "/lib/frag/bluenoise.glsl"
#include "/lib/light/ao.glsl"

/* ------ promo-outline effect from CaptTatsu's BSL shaders ------ */

vec2 promooutlineoffset[4] = vec2[4](vec2(-1.0,1.0),vec2(0.0,1.0),vec2(1.0,1.0),vec2(1.0,0.0));

float promooutline(sampler2D depth){
	float ph = 1.5/1080.0;
	float pw = ph/aspectRatio;

	float outlinec = 1.0;
	float z = depthLinear(texture(depth,coord.xy).r)*far;
	float totalz = 0.0;
	float maxz = 0.0;
	float sampleza = 0.0;
	float samplezb = 0.0;

	for (int i = 0; i < 4; i++){
		sampleza = depthLinear(texture(depth,coord.xy+vec2(pw,ph)*promooutlineoffset[i]).r)*far;
		maxz = max(sampleza,maxz);

		samplezb = depthLinear(texture(depth,coord.xy-vec2(pw,ph)*promooutlineoffset[i]).r)*far;
		maxz = max(samplezb,maxz);

		outlinec*= clamp(1.0-((sampleza+samplezb)-z*2.0)*32.0/z,0.0,1.0);

		totalz += sampleza+samplezb;
	}
	float outlinea = 1.0-clamp((z*8.0-totalz)*64.0-0.08*z,0.0,1.0)*(clamp(1.0-(z*8.0-totalz)*16.0/z,0.0,1.0));
	float outlineb = clamp(1.0+32.0*(z-maxz)/z,0.0,1.0);
	float outline = (0.25*(outlinea*outlineb)+0.75)*(0.75*(1.0-outlinec)*outlineb+1.0);

    outline     = outline - 1.0;
    outline     = max0(outline) * sqrt2 + outline * 1.5;
    outline     = outline + 1.0;

	return clamp(outline, 0.0, 4.0);
}

void main() {
    sceneColor  = texture(colortex0, coord).rgb;

    decompressSceneColor(sceneColor);

    float sceneDepth = stex(depthtex1).x;

    if (landMask(sceneDepth)) {
        vec3 viewPos        = screenToViewSpace(vec3(coord, sceneDepth));
        vec3 scenePos       = viewToSceneSpace(viewPos);

        vec4 auxData        = texture(colortex2, coord);

        bool cloud          = int(auxData.z * 65535.0) == 200;

        vec3 sceneNormal    = decodeNormal(auxData.xy);

        float outline       = promooutline(depthtex1);

        if (!cloud) {

            #ifdef ambientOcclusionToggle
                #ifdef directionalSSAO
                    sceneColor *= getDSSAO(depthtex1, sceneNormal, sceneDepth, coord, ditherBluenoise());
                #else
                    sceneColor *= getSSAO(depthtex1, sceneDepth, coord, ditherBluenoise());
                #endif
            #endif

            #ifdef outlineShimmerToggle
            sceneColor *= max(outline, 0.85);
            #endif

        } 
        #ifdef outlineShimmerToggle
        else {

            float dist 	= length(viewPos)/far;
		        dist 	= max((dist-0.25)*2.0, 0.0);
	        float alpha = 1.0-exp2(-dist*2.0);

            sceneColor *= mix(max(outline, 0.95), 1.0, alpha);            
        }
        #endif
    }

    compressSceneColor(sceneColor);

    transparency    = vec4(0.0);
}