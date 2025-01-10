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

#ifndef gTRANSLUCENT
/*DRAWBUFFERS:02*/
layout(location = 0) out vec4 sceneColor;
layout(location = 1) out vec4 sceneData;
#else
/*DRAWBUFFERS:34*/
layout(location = 0) out vec4 sceneColor;
layout(location = 1) out vec4 sceneData;
#endif

#include "/lib/head.glsl"

in mat2x2 coord;

flat in vec3 normal;

in vec4 tint;

flat in mat4x3 colorPalette;

#ifdef gTEXTURED
    uniform sampler2D gcolor;

    #ifdef normalmapEnabled
        uniform sampler2D normals;

        flat in mat3 tbn;

        vec3 decodeNormalTexture(vec3 ntex) {
            vec3 nrm    = ntex * 2.0 - (254.0 * rcp(255.0));

            #if normalmapFormat==0
                nrm.z  = sqrt(saturate(1.0 - dot(nrm.xy, nrm.xy)));
            #elif normalmapFormat==1
                nrm    = normalize(nrm);
            #endif

            return normalize(nrm * tbn);
        }
    #endif
#endif

#ifdef gTERRAIN
    flat in int matID;

    in float viewDist;

    in vec3 viewPos;

    in vec3 worldPos;

    uniform sampler2D noisetex;

    uniform float frameTimeCounter;

    uniform vec3 sunDirView;
    uniform vec3 moonDirView;
    uniform vec3 upDirView;

    uniform mat4 gbufferModelView, gbufferModelViewInverse;
#endif

uniform sampler2D lightmap;

uniform int frameCounter;
uniform int isEyeInWater;

#ifdef gENTITY
    uniform int entityId;
    uniform vec4 entityColor;
#endif

uniform vec3 sunDir, moonDir, lightDir, upDir;

uniform vec4 daytime;

float diffuseLambert(vec3 normal, vec3 lightDir) {
    float lamb  = dot(normal, lightDir);
        lamb    = saturate(lamb);
    return lamb;
}

vec3 getDirectLighting(vec3 normal, vec3 color, float skyOcclusion, vec3 lightDir) {
    float diffuse   = diffuseLambert(normal, lightDir);

    float lambert   = mix(dot(normal, upDir), dot(normal, lightDir), 0.66) * 0.33 + 0.67;

    float intensity = 0.67 * diffuse + 0.33 * lambert;
        //intensity  *= lambert;

    #ifdef gTERRAIN
        if (matID == 2) intensity = mix(intensity, 1.0 * diffuseLambert(lightDir, upDir), 0.5);
    #endif

    float occlusion = (pow8(skyOcclusion));

    return color * intensity * occlusion;
}

vec3 getSkyLighting(vec3 normal, vec3 color, float skyOcclusion) {
    float diffuse   = diffuseLambert(normal, upDir);

    float lambert   = dot(normal, upDir) * 0.33 + 0.67;

    float intensity = 0.33 * diffuse + 0.67 * lambert;

    float occlusion = pow4(skyOcclusion);

    return color * intensity * occlusion * 0.5;
}

#include "/lib/frag/gradnoise.glsl"

#if (defined gTERRAIN && defined gTRANSLUCENT)
    #include "/lib/util/bicubic.glsl"
    #include "/lib/atmos/waterWaves.glsl"
    vec3 waterNormal() {
        vec3 pos    = worldPos;

        float dstep   = 0.01 + (1.0 - exp(-viewDist * rcp(32.0))) * 0.03;

        vec2 delta;
            delta.x     = waterWaves(pos + vec3( dstep, 0.0, -dstep));
            delta.y     = waterWaves(pos + vec3(-dstep, 0.0,  dstep));
            delta      -= waterWaves(pos + vec3(-dstep, 0.0, -dstep));

        return normalize(vec3(-delta.x, 2.0 * dstep, -delta.y));
    }

    #include "/lib/atmos/skyGradient.glsl"

    float fresnelSchlick(float f0, float VoH) {
        return saturate(f0 + (1.0 - f0) * pow5(1.0 - VoH));
    }

    float specularGGX(vec3 normal, vec3 svec, vec2 material, vec3 lightvec) {
        float f0  = material.y;
        float roughness = sqr(material.x);

        vec3 h      = lightvec - svec;
        float hn    = inversesqrt(dot(h, h));
        float hDotL = saturate(dot(h, lightvec)*hn);
        float hDotN = saturate(dot(h, normal)*hn);
        float nDotL = saturate(dot(normal, lightvec));
        float denom = (hDotN * roughness - hDotN) * hDotN + 1.0;
        float D     = roughness / (pi * denom * denom);
        float F     = f0 + (1.0-f0) * exp2((-5.55473*hDotL-6.98316)*hDotL);
        float k2    = 0.25 * roughness;

        return nDotL * D * F / (hDotL * hDotL * (1.0-k2) + k2);
    }

    vec3 getWaterFauxReflection(vec3 color, vec3 sceneNormal) {
        vec3 viewNormal     = normalize(mat3(gbufferModelView) * sceneNormal);
        vec3 viewDir        = -normalize(viewPos);
        vec3 reflectedViewDir = reflect(viewDir, viewNormal);
        vec3 skyColor       = getSky(reflectedViewDir, colorPalette[3], colorPalette[2], colorPalette[0], vec3(0.0));
            skyColor       *= 1.0 - sstep((mat3(gbufferModelViewInverse) * reflectedViewDir).y, -0.1, 0.0) * 0.8;

        float vDotN         = max0(dot(viewDir, viewNormal));

        float fresnel       = fresnelSchlick(0.04, vDotN);

        float occlusion     = cube(linStep(coord[1].y, 0.75, 0.95));

        return mix(color, skyColor, fresnel * occlusion) + occlusion * specularGGX(viewNormal, -viewDir, vec2(0.02, 0.04), sunDirView) * colorPalette[0];
    }
#endif

void main() {
    vec3 sceneNormal  = normal;
    vec2 lmap   = coord[1];

    float ao    = 1.0;

    int matID_out = 1;

    #ifdef gTEXTURED
        sceneColor          = texture(gcolor, coord[0]);
        if (sceneColor.a<0.1) discard;
            sceneColor.rgb *= tint.rgb;

        #if !(defined gENTITY && MC_VERSION >= 11500)
            #ifdef normalmapEnabled
                sceneNormal     = decodeNormalTexture(texture(normals, coord[0]).rgb);
            #endif
        #endif

        #ifdef gTERRAIN
            ao              = tint.a;

            matID_out       = matID;

            #ifdef gTRANSLUCENT
                if (matID == 102) {
                    #ifdef overrideWaterTexture
                    float textureAlpha = cube(sceneColor.a);
                    sceneColor  = vec4(waterColorRed, waterColorGreen, waterColorBlue, max(waterColorAlpha, 0.101)) * vec4(vec3(0.15 + textureAlpha * 0.85), 1.0);
                    #else
                    sceneColor.a = mix(0.101, 0.25, linStep(sceneColor.a, 0.1, 1.0));
                    #endif
                    sceneNormal = waterNormal();
                }
            #endif
        #else
            #ifndef gTRANSLUCENT
                #ifdef gBASIC
                sceneColor.a = 1.0;
                #else
                sceneColor.a  = round(sceneColor.a * tint.a + ditherGradNoiseTemporal() - 0.5);
                #endif
            #endif
        #endif

        #ifdef gENTITY
            if (entityId == 999) discard;
            sceneColor.rgb = mix(sceneColor.rgb, entityColor.rgb, entityColor.a);
        #endif
    #else
        sceneColor          = tint;
        if (sceneColor.a<0.01) discard;

            sceneColor.a    = 1.0;

        if (minOf(sceneColor.rgb) < 0.01) lmap.xy = vec2(0.0);
    #endif

    sceneColor.rgb  = toLinear(sceneColor.rgb);

    vec3 lighting   = getSkyLighting(sceneNormal, colorPalette[1], lmap.y) * (cube(ao) * 0.95 + 0.05);

    if (daytime.w < 1.0) lighting   += getDirectLighting(sceneNormal, colorPalette[0], lmap.y, sunDir) * ao * sqr(1.0 - daytime.w);
    if (daytime.w > 0.0) lighting   += getDirectLighting(sceneNormal, moonlightColor, lmap.y, moonDir) * ao * daytime.w;
    
        lighting    = max(lighting, 0.01 * ao);

    #define lightmapColMod vec3(1.0, 0.85, 0.6)

    if (lmap.x > 0.0) {
        vec3 lmapcol = texture(lightmap, vec2(clamp(lmap.x, 0.55 / 16.0, 15.5 / 16.0), 0.5 / 16.0)).rgb;
		lmapcol 	= toLinear(lmapcol) * sqrt3;
        lmapcol    *= cubeSmooth(sqrt(linStep(lmap.x, 0.5 / 16.0, 6.5 / 16.0)));
        //lmapcol     = saturate(normalize(lmapcol)) * pow5(lmap.x);
        lighting   += lmapcol * mix(lightmapColMod * normalize(sqr(lightmapColMod)), lightmapColMod, (sqr(lmap.x))) * ao;
    }

    sceneColor.rgb *= lighting;

    vec3 desatColor = vec3(getLuma(sceneColor.rgb)) * vec3(0.4, 0.6, 1.0);
    float desatAlpha = cubeSmooth(lmap.y);
        desatAlpha  = mix(desatAlpha, 0.0, sqr(daytime.w));
        desatAlpha  = max(desatAlpha, sqrt(lmap.x));

    sceneColor.rgb  = mix(desatColor, sceneColor.rgb, desatAlpha * 0.9 + 0.1);


    #if (defined gTEXTURED && defined gTERRAIN && defined gTRANSLUCENT)
        if (matID == 102 && isEyeInWater == 0) {
            sceneColor.rgb = getWaterFauxReflection(sceneColor.rgb, sceneNormal);
        }
    #endif

    compressSceneColor(sceneColor.rgb);

    sceneColor      = vec4(sceneColor.rgb, saturate(sceneColor.a));
    sceneData.xy    = encodeNormal(sceneNormal);
    sceneData.zw    = vec2(float(matID_out) / 65535.0, 1.0);
}