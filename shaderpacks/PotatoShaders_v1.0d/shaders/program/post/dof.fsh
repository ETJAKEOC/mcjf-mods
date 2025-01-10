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

/*
    const bool colortex0MipmapEnabled = true;
*/

/*DRAWBUFFERS:0*/
layout(location = 0) out vec3 sceneColor;

#include "/lib/head.glsl"

in vec2 coord;

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D depthtex2;

uniform float aspectRatio;
uniform float centerDepthSmooth;
uniform float viewWidth, viewHeight;

uniform vec2 viewSize;

uniform mat4 gbufferProjection, gbufferProjectionInverse;


#include "/lib/util/poisson.glsl"

float screenToViewSpace(float depth) {
	depth = depth * 2.0 - 1.0;
	return gbufferProjectionInverse[3].z / (gbufferProjectionInverse[2].w * depth + gbufferProjectionInverse[3].w);
}

#define camFStops 2.8   //[0.8 1.4 2.0 2.8 3.2 3.6 4.0 4.4 4.8 5.6 6.4 7.2 8.0 9.6 12.8 16.0]
#define camSensorWidth 35   //[16 20 25 30 35 40 50 60 70 80]

const float sensorWidth     = camSensorWidth * 1e-3;

float getCoC(float dist, float focus, float fLength, float aperture) {
    float n     = aperture * (fLength * (dist - focus));
    float d     = dist * (focus - fLength);

    return abs(n) * rcp(max(d, 1e-20)) * 1e3 * aperture * tau;
}

vec3 getBokehDoF(sampler2D scene, sampler2D depthtex, vec2 coord) {
    float fLength   = 0.5 * sensorWidth * gbufferProjection[0].x;
    float aperture  = fLength / camFStops;

    float pixelDepth = texture(depthtex, coord).x;
    if (pixelDepth < 0.7) return textureLod(scene, coord, 0).rgb;

    float dist  = screenToViewSpace(pixelDepth);
    float focusDist = screenToViewSpace(centerDepthSmooth);

    float pixelCoC  = getCoC(dist, focusDist, aperture, fLength);

    vec2 dispersionDir = (normalize(coord - 0.5));

    vec3 result     = vec3(0.0);
    uint weight     = 0;

    #if DoFQuality == 0
    for (uint i = 0; i < 30; i++) {
        vec2 bokeh  = poisson30[i];
    #elif DoFQuality == 1
    for (uint i = 0; i < 45; i++) {
        vec2 bokeh  = poisson45[i];
    #elif DoFQuality == 2
    for (uint i = 0; i < 60; i++) {
        vec2 bokeh  = poisson60[i];
    #endif

        vec2 offset     = bokeh * vec2(1.0, aspectRatio) * pixelCoC;

        float depth     = screenToViewSpace(texture(depthtex, coord + offset).x);

        float CoC       = getCoC(depth, focusDist, aperture, fLength);

        float lod       = clamp(log2(CoC * 0.5 * viewSize.y), 0.0, 4.0);

        vec2 newOffset  = bokeh * vec2(1.0, aspectRatio) * CoC;

        vec3 color      = textureLod(scene, coord + newOffset, lod).rgb;

        #ifdef DoFChromaDispersion
        vec2 chromaOffset = dispersionDir * vec2(1.0, aspectRatio) * 4e-1 * CoC;

            color.r   = textureLod(scene, coord + newOffset + chromaOffset, lod).r;
            color.b   = textureLod(scene, coord + newOffset - chromaOffset, lod).b;
        #endif
        
        result     += color;
        weight++;
    }

    result /= max(weight, 1);

    return result;
}

void main() {
    sceneColor  = stexLod(colortex0, 0).rgb;

    #ifdef DoFToggle
        sceneColor  = getBokehDoF(colortex0, depthtex0, coord);
    #endif
}