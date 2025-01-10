flat out mat4x3 colorPalette;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform vec4 daytime;

void getColorPalette() {
	vec3 sunlightSunrise 	= vec3(sunlightSunriseR, sunlightSunriseG, sunlightSunriseB) * sqrt2 * sunlightSunriseL;
	vec3 sunlightNoon 		= vec3(sunlightNoonR, sunlightNoonG, sunlightNoonB) * sqrt3 * sunlightNoonL;
	vec3 sunlightSunset 	= vec3(sunlightSunsetR, sunlightSunsetG, sunlightSunsetB) * sqrt2 * sunlightSunsetL;
	vec3 sunlightNight 		= vec3(sunlightNightR, sunlightNightG, sunlightNightB) * 0.25 * sunlightNightL;

    colorPalette[0]         = sunlightSunrise * daytime.x + sunlightNoon * daytime.y + sunlightSunset * daytime.z + sunlightNight * daytime.w;

	vec3 skylightSunrise 	= vec3(skylightSunriseR, skylightSunriseG, skylightSunriseB) * 0.7 * skylightSunriseL;
	vec3 skylightNoon 		= vec3(skylightNoonR, skylightNoonG, skylightNoonB) * 0.9 * skylightNoonL;
	vec3 skylightSunset 	= vec3(skylightSunsetR, skylightSunsetG, skylightSunsetB) * 0.7 * skylightSunsetL;
	vec3 skylightNight 		= vec3(skylightNightR, skylightNightG, skylightNightB) * 0.2 * skylightNightL;

    colorPalette[1]         = skylightSunrise * daytime.x + skylightNoon * daytime.y + skylightSunset * daytime.z + skylightNight * daytime.w;

	vec3 fogSunrise 	    = vec3(fogcolSunriseR, fogcolSunriseG, fogcolSunriseB) * 1.75 * fogcolSunriseL;
	vec3 fogNoon 	        = vec3(fogcolNoonR, fogcolNoonG, fogcolNoonB) * 1.85 * fogcolNoonL;
	vec3 fogSunset 	        = vec3(fogcolSunsetR, fogcolSunsetG, fogcolSunsetB) * 1.6 * fogcolSunsetL;
	vec3 fogNight 	        = vec3(fogcolNightR, fogcolNightG, fogcolNightB) * 0.06 * fogcolNightL;

    #ifdef vanillaFogColor
        fogNoon             = pow(fogColor, vec3(2.2)) * 1.85;
    #endif

	colorPalette[2]         = fogSunrise * daytime.x + fogNoon * daytime.y + fogSunset * daytime.z + fogNight * daytime.w;

    #ifdef vanillaSkyColor
        colorPalette[3]		= toLinear(skyColor);
        colorPalette[3]	   *= vec3(0.9, 0.85, 1.0);
    #else
        vec3 skySunrise 	= vec3(skycolSunriseR, skycolSunriseG, skycolSunriseB) * 0.5 * skycolSunriseL;
        vec3 skyNoon 	    = vec3(skycolNoonR, skycolNoonG, skycolNoonB) * 1.0 * skycolNoonL;
        vec3 skySunset 	    = vec3(skycolSunsetR, skycolSunsetG, skycolSunsetB) * 0.5 * skycolSunsetL;
        vec3 skyNight 	    = vec3(skycolNightR, skycolNightG, skycolNightB) * 0.005 * skycolNightL;

        colorPalette[3]     = skySunrise * daytime.x + skyNoon * daytime.y + skySunset * daytime.z + skyNight * daytime.w;
    #endif

}