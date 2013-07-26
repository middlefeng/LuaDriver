

#version 150

uniform vec4 vColor;
out vec4 g_FragColor;

void main(void)
{
	g_FragColor = vColor;
}