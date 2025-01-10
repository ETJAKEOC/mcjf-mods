flat out mat2x3 colorPalette;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform vec4 daytime;

void getColorPalette() {

    colorPalette[0]         = toLinear(fogColor);
    colorPalette[0]         = mix(vec3(normalize(colorPalette[0])) / pi, colorPalette[0], 0.5);

    colorPalette[1]		    = toLinear(fogColor) * 0.125;

}