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

out mat2x2 coord;

flat out vec3 normal;

out vec4 tint;

uniform vec2 taaOffset;

uniform mat4 gbufferModelViewInverse;

#include "/lib/atmos/colorsNether.glsl"

#ifdef gTEXTURED
    #ifdef normalmapEnabled
        flat out mat3 tbn;

        attribute vec4 at_tangent;
    #endif
#endif

#ifdef gTERRAIN
    flat out int matID;

    out float viewDist;

    out vec3 viewPos;

    out vec3 worldPos;

    attribute vec4 mc_Entity;
    attribute vec4 mc_midTexCoord;

    uniform vec3 cameraPosition;

    uniform mat4 gbufferModelView;

    #ifdef windEffectsEnabled
        #include "/lib/vert/wind.glsl"
    #endif
#endif

void main() {
    coord[0]    = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    coord[1]    = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    coord[1].x  = linStep(coord[1].x, rcp(24.0), 1.0);
    coord[1].y  = linStep(coord[1].y, rcp(16.0), 1.0);

    tint        = gl_Color;

    vec4 pos    = gl_Vertex;
        pos     = viewMAD(gl_ModelViewMatrix, pos.xyz).xyzz;

    #ifdef gTERRAIN
        viewDist    = length(pos.xyz);
        viewPos     = pos.xyz;
        worldPos    = viewMAD(gbufferModelViewInverse, pos.xyz) + cameraPosition;
    #endif

    #if (defined gTERRAIN && defined windEffectsEnabled)
        pos.xyz = viewMAD(gbufferModelViewInverse, pos.xyz);

        bool windLod    = length(pos.xz) < 192.0;

        if (windLod) {
            bool topvert    = (gl_MultiTexCoord0.t < mc_midTexCoord.t);

            if (mc_Entity.x == 10021 || (mc_Entity.x == 10022 && topvert) || (mc_Entity.x == 10023 && topvert) || mc_Entity.x == 10024) {
                vec2 windOffset = vertexWindEffect(worldPos, 0.18, 1.0);

                if (mc_Entity.x == 10021) pos.xyz += windOffset.xyy*0.4;
                else if (mc_Entity.x == 10023 || (mc_Entity.x == 10024 && !topvert)) pos.xz += windOffset*0.5;
                else pos.xz += windOffset;
            }
        }

        pos.xyz = viewMAD(gbufferModelView, pos.xyz);
    #endif

        pos     = pos.xyzz * diag4(gl_ProjectionMatrix) + vec4(0.0, 0.0, gl_ProjectionMatrix[3].z, 0.0);

    #ifdef taaEnabled
        pos.xy += taaOffset*pos.w;
    #endif

    normal 	= mat3(gbufferModelViewInverse) * normalize(gl_NormalMatrix*gl_Normal);

    #ifdef gTEXTURED
        #ifdef normalmapEnabled
            vec3 viewTangent = normalize(gl_NormalMatrix*at_tangent.xyz);
            vec3 viewBinormal = normalize(gl_NormalMatrix*cross(at_tangent.xyz, gl_Normal.xyz) * at_tangent.w);
            vec3 tangent = mat3(gbufferModelViewInverse) * viewTangent;
            vec3 binormal = mat3(gbufferModelViewInverse) * viewBinormal;

            tbn     = mat3(tangent.x, binormal.x, normal.x,
                        tangent.y, binormal.y, normal.y,
                        tangent.z, binormal.z, normal.z);
        #endif
    #endif
        
    gl_Position = pos;

    getColorPalette();

    #ifdef gTERRAIN
        matID  = 1;
        
        #ifdef gTRANSLUCENT
            matID  = 101;
        #endif

        if (
         mc_Entity.x == 10022 ||
         mc_Entity.x == 10023 ||
         mc_Entity.x == 10024 ||
         mc_Entity.x == 10025 ||
         mc_Entity.x == 10202) matID = 2;

        if (
         mc_Entity.x == 10021) matID = 4;

        if (mc_Entity.x == 10301 ||
         mc_Entity.x == 10002) matID = 5;

        if (mc_Entity.x == 10001) matID = 102;
    #endif
}