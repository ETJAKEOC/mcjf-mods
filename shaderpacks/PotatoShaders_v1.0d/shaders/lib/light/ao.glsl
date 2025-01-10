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
    SSAO based on BSL Shaders by Capt Tatsu with permission
*/

vec2 offsetDist(float x) {
	float n = fract(x * 8.0) * 3.1415;
    return vec2(cos(n), sin(n)) * x;
}

float getSSAO(sampler2D depthtex, float depth, vec2 coord, float dither) {
    const uint steps = 4;
    const float radius = 1.0;

    bool hand       = depth<0.56;
        depth       = depthLinear(depth);

    float currStep  = 0.2 * dither + 0.2;
	float fovScale  = gbufferProjection[1][1] / 1.37;
	float distScale = max((far - near) * depth + near, 5.0);
	vec2 scale      = radius * vec2(1.0 / aspectRatio, 1.0) * fovScale / distScale;

    float ao = 0.0;

    for (uint i = 0; i < steps; ++i) {
		vec2 offset = offsetDist(currStep) * scale;
		float mult  = (0.7 / radius) * (far - near) * (hand ? 1024.0 : 1.0);

		float sampleDepth = depthLinear(texture(depthtex, coord + offset).r);
		float sample0 = (depth - sampleDepth) * mult;
		float angle = clamp(0.5 - sample0, 0.0, 1.0);
		float dist  = clamp(0.25 * sample0 - 1.0, 0.0, 1.0);

		sampleDepth = depthLinear(texture(depthtex, coord - offset).r);
		sample0      = (depth - sampleDepth) * mult;
		angle      += clamp(0.5 - sample0, 0.0, 1.0);
		dist       += clamp(0.25 * sample0 - 1.0, 0.0, 1.0);
		
		ao         += (clamp(angle + dist, 0.0, 1.0));
		currStep   += 0.2;
    }
	ao *= 1.0 / float(steps);
	
	return ao;
}

float getDSSAO(sampler2D depthtex, vec3 sceneNormal, float depth, vec2 coord, float dither) {
    const uint steps = 6;
    const float baseRadius = sqrt2;

    float radius    = baseRadius * (0.75 + abs(1.0-dot(sceneNormal, vec3(0.0, 1.0, 0.0))) * 0.5);

    bool hand       = depth < 0.56;
        depth       = depthLinear(depth);

    float currStep  = 0.2 * dither + 0.2;
	float fovScale  = gbufferProjection[1][1] / 1.37;
	float distScale = max((far - near) * depth + near, 5.0);
	vec2 scale      = radius * vec2(1.0 / aspectRatio, 1.0) * fovScale / distScale;

    float ao = 0.0;

    for (uint i = 0; i < steps; ++i) {
		vec2 offset = offsetDist(currStep) * scale;
		float mult  = (0.7 / radius) * (far - near) * (hand ? 1024.0 : 1.0);

		float sampleDepth = depthLinear(texture(depthtex, coord + offset).r);
		float sample0 = (depth - sampleDepth) * mult;
		float angle = clamp(0.5 - sample0, 0.0, 1.0);
		float dist  = clamp(0.25 * sample0 - 1.0, 0.0, 1.0);

		sampleDepth = depthLinear(texture(depthtex, coord - offset).r);
		sample0     = (depth - sampleDepth) * mult;
        angle      += clamp(0.5 - sample0, 0.0, 1.0);
        dist       += clamp(0.25 * sample0 - 1.0, 0.0, 1.0);
		
		ao         += (clamp(angle + dist, 0.0, 1.0));
		currStep   += 0.2;
    }
	ao *= 1.0 / float(steps);
	
	return ao;
}