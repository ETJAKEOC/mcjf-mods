vec3 getSky(vec3 viewDir, vec3 zenithColor, vec3 fogColor, vec3 sunColor, vec3 stars) {
    vec3 horizonVector0     = normalize(-upDirView + viewDir);
    vec3 horizonVector1     = normalize(upDirView + viewDir);
    vec3 sunGlowVector      = normalize(sunDirView + viewDir);
    vec3 moonGlowVector     = normalize(moonDirView + viewDir);

    float horizonGradTop    = dot(horizonVector0, viewDir);
    float horizonGradBottom = dot(horizonVector1, viewDir);

    float horizonFade       = linStep(horizonGradBottom, 0.3, 0.8);
        horizonFade         = pow6(horizonFade);

    float horizonGrad       = 1.0-max(horizonGradBottom*0, horizonGradTop);

    float horizon           = linStep(horizonGrad, 0.12, 0.30);
        horizon             = pow6(horizon);

    float sunGrad           = 1.0-dot(sunGlowVector, viewDir);
    float moonGrad          = 1.0-dot(moonGlowVector, viewDir);

    float sunGlow           = linStep(sunGrad, 0.5, 0.99);
        sunGlow             = pow6(sunGlow)*0.5;

    float moonGlow          = linStep(moonGrad, 0.5, 0.99);
        moonGlow            = pow6(moonGlow)*0.5;

    float sunGlowHorizon    = linStep(sunGrad, 0.0, 0.99);
        sunGlowHorizon      = cube(sunGlowHorizon)*(horizonFade + horizon) * finv(sqrt(daytime.w)) * finv(daytime.y*0.8);

    vec3 sky    = zenithColor * 0.8 + vec3(0.4, 0.6, 1.0) * 0.013 * daytime.w;
        sky     = mix(sky, fogColor, horizonFade*0.75);
        sky     = mix(sky, fogColor, horizon*0.8);
        sky    *= cube(1.0-saturate(sunGlowHorizon));
        sky    += sunColor * sunGlowHorizon*6.0;
        sky    += sunColor * sunGlow * finv(daytime.w);
        sky    += moonlightColor * moonGlow;
        sky    += stars * (daytime.w) * pow4(finv(max(horizonFade, horizon)));

    return sky;
}