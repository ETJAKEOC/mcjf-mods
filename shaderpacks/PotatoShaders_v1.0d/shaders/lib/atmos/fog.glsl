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

vec3 getFog(vec3 color, vec3 position, vec3 viewDir) {

    #ifdef fogEnabled
	float dist 	= length(position)/far;
		dist 	= max((dist-fogStart) * 2.0, 0.0);
        
	float alpha = 1.0-exp2(-dist * fogFalloff);
        alpha  *= sqr(1.0 - max0(normalize(position).y));

	color 	= mix(color, getSky(viewDir, colorPalette[3], colorPalette[2], colorPalette[0], vec3(0.0)), saturate(sqr(alpha)));
    #endif

	return color;
}

vec3 getCloudFog(vec3 color, vec3 position, vec3 viewDir){
	float dist 	= length(position)/far;
		dist 	= max((dist-0.25)*2.0, 0.0);
	float alpha = 1.0-exp2(-dist * fogFalloff);

	color 	= mix(color, getSky(viewDir, colorPalette[3], colorPalette[2], colorPalette[0], vec3(0.0)), saturate(sqr(alpha)));

	return color;
}

vec3 getWaterFog(vec3 color, float dist, vec3 viewDir, float scatterMult){
    #ifdef waterFogEnabled
	    dist 	= dist / pi;
		dist 	= max((dist), 0.0) * waterFogFalloff;
        
	float alpha = 1.0-exp(-dist / euler);

    float desatAlpha = mix(1.0, 0.0, sqr(daytime.w));

    vec3 waterCoeff     = vec3(waterFogRed, waterFogGreen, waterFogBlue);
        waterCoeff     /= maxOf(waterCoeff);

    vec3 extinctCoeff   = 1.0 / max(waterCoeff, vec3(1e-6));
        extinctCoeff   /= maxOf(extinctCoeff);

    vec3 extinctionCoeff = extinctCoeff * halfPi;
        extinctionCoeff = mix(vec3(avgOf(extinctionCoeff)), extinctionCoeff, desatAlpha * 0.9 + 0.1);

    color  *= exp(-dist * extinctionCoeff);

    vec3 scatterColor = (colorPalette[1] * waterCoeff / tau) * scatterMult;

    vec3 desatScatter = vec3(getLuma(scatterColor)) * vec3(0.4, 0.6, 1.0);

    scatterColor    = mix(desatScatter, scatterColor, desatAlpha * 0.9 + 0.1);

	color 	= mix(color, scatterColor, saturate(sqr(alpha)));
    #endif

	return color;
}