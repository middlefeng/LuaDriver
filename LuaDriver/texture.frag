

#version 150

in vec2 g_Tex;
out vec4 g_FragColor;
uniform sampler2D sTex;

void main(void)
{
	g_FragColor = texture(sTex, g_Tex);
}