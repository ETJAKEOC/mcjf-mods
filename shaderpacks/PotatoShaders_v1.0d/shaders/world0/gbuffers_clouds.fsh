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

#if MC_VERSION >= 11500
    /*DRAWBUFFERS:34*/
    layout(location = 0) out vec4 sceneColor;
    layout(location = 1) out vec4 sceneData;
#else
    /*DRAWBUFFERS:02*/
    layout(location = 0) out vec4 sceneColor;
    layout(location = 1) out vec4 sceneData;
#endif

#include "/lib/head.glsl"

in vec2 coord;

in vec3 viewPos;
in vec3 scenePos;

flat in vec3 normal;

in vec4 tint;

flat in mat4x3 colorPalette;

uniform sampler2D gcolor;

uniform float far;

uniform vec3 sunDirView, sunDir;
uniform vec3 moonDirView, moonDir;
uniform vec3 upDirView, upDir;

uniform vec4 daytime;

#include "/lib/atmos/skyGradient.glsl"

vec3 getFog(vec3 color){
	float dist 	= length(scenePos)/far;
		dist 	= max((dist-0.25)*2.0, 0.0);
	float alpha = 1.0-exp2(-dist * fogFalloff);

	color 	= mix(color, getSky(-normalize(viewPos), colorPalette[3], colorPalette[2], colorPalette[0], vec3(0.0)), saturate(sqr(alpha)));

	return color;
}

float mieHG(float cosTheta, float g) {
    float mie   = 1.0 + sqr(g) - 2.0*g*cosTheta;
        mie     = (1.0 - sqr(g)) / ((4.0*pi) * mie*(mie*0.5+0.5));
    return mie;
}

vec3 cloudShading(vec3 color) {
    float lambert 	= dot(normal, sunDir);
    float vDotL 	= dot(normalize(viewPos), sunDirView)*0.5+0.5;
    float phase     = mix(mieHG(vDotL, 0.75), mieHG(-vDotL, 0.45), 0.4) * 2.6;

    vec3 color0 	= saturate(lambert * 0.66 + 0.33) * colorPalette[0] * phase;
        color0     += colorPalette[0]*(phase * 0.2 + 0.04);

    float lambertM 	= dot(normal, moonDir);
    float vDotLM 	= dot(normalize(viewPos), moonDirView)*0.5+0.5;
    float phaseM    = mix(mieHG(vDotLM, 0.75), mieHG(-vDotLM, 0.45), 0.4) * 2.6;

    vec3 color1 	= saturate(lambertM * 0.66 + 0.33) * moonlightColor * phaseM;
        color1     += moonlightColor * (phaseM * 0.2 + 0.04);

    float lambertu 	= dot(normal, upDir);

    color   = mix(color0, color1, sqr(daytime.w));

    color  += (colorPalette[3] + colorPalette[2] * 0.6)*(sqrt(saturate(lambertu))*0.85+0.15);

    return color;
}

void main() {
    sceneColor      = texture(gcolor, coord);
    if (sceneColor.a<0.1) discard;
        sceneColor.rgb *= tint.rgb;

    sceneColor.rgb  = toLinear(sceneColor.rgb);
	sceneColor.rgb  = cloudShading(sceneColor.rgb);

    #if MC_VERSION < 11500
	sceneColor.rgb  = getFog(sceneColor.rgb);
    #endif

    compressSceneColor(sceneColor.rgb);

    sceneColor      = vec4(sceneColor.rgb, saturate(sceneColor.a * 0.85));
    sceneData.xy    = encodeNormal(normal);
    sceneData.zw    = vec2(200.0 / 65535.0, 1.0);
}