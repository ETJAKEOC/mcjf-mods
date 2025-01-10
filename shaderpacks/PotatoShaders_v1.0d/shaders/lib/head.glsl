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

#include "/settings.glsl"
#include "internal.glsl"
#include "util/const.glsl"
#include "util/macros.glsl"
#include "util/functions.glsl"

const float compressionCoeff    = 4.0;

void compressSceneColor(inout vec3 color) {
    color   = clamp16F(color) / compressionCoeff;
}
void decompressSceneColor(inout vec3 color) {
    color   = (color * compressionCoeff);
}

vec3 toLinear(vec3 x){
    vec3 temp = mix(x / 12.92, pow(.947867 * x + .0521327, vec3(2.4)), step(0.04045, x));
    return max(temp, 0.0);
}
vec3 linearToSRGB(vec3 x){
    return mix(x * 12.92, clamp16F(pow(x, vec3(1./2.4)) * 1.055 - 0.055), step(0.0031308, x));
}

/*
    Normals encoding and decoding based on Spectrum by Zombye
*/
vec2 encodeNormal(in vec3 normal) {
    normal.xy /= abs(normal.x) + abs(normal.y) + abs(normal.z);
    return (normal.z <= 0.0 ? (1.0 - abs(normal.yx)) * vec2(normal.x >= 0.0 ? 1.0 : -1.0, normal.y >= 0.0 ? 1.0 : -1.0) : normal.xy) * 0.5 + 0.5;
}
vec3 decodeNormal(in vec2 encodedNormal) {
    encodedNormal = encodedNormal * 2.0 - 1.0;
	vec3 normal = vec3(encodedNormal, 1.0 - abs(encodedNormal.x) - abs(encodedNormal.y));
	float t = max(-normal.z, 0.0);
	normal.xy += vec2(normal.x >= 0.0 ? -t : t, normal.y >= 0.0 ? -t : t);
	return normalize(normal);
}