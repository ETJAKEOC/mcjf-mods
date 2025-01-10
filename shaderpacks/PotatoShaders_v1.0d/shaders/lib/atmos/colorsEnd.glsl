flat out mat2x3 colorPalette;

uniform vec3 fogColor;
uniform vec3 skyColor;

uniform vec4 daytime;

void getColorPalette() {

    colorPalette[0]         = vec3(0.55, 0.3, 1.0) * 0.1;

    colorPalette[1]		    = vec3(0.5, 0.2, 1.0) * 0.005;

}