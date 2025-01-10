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

vec3 getFog(vec3 color, vec3 position, vec3 viewDir){
	float dist 	= length(position)/far;
		dist 	= max((dist)*2.0, 0.0);
        
	float alpha = 1.0-exp2(-dist * pi);

	color 	= mix(color, colorPalette[1], saturate(alpha));

	return color;
}

vec3 getWaterFog(vec3 color, float dist, vec3 viewDir){
	    dist 	= dist / pi;
		dist 	= max((dist), 0.0);
        
	float alpha = 1.0-exp(-dist / euler);

    float desatAlpha = mix(1.0, 0.0, sqr(daytime.w));

    vec3 extinctionCoeff = vec3(1.0, 0.4, 0.2) * halfPi;
        extinctionCoeff = mix(vec3(avgOf(extinctionCoeff)), extinctionCoeff, desatAlpha * 0.9 + 0.1);

    color  *= exp(-dist * extinctionCoeff);

    vec3 scatterColor = colorPalette[1] * vec3(0.2, 0.45, 1.0) / tau;

	color 	= mix(color, scatterColor, saturate(sqr(alpha)));

	return color;
}