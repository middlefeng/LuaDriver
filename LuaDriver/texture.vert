
#version 150

uniform mat4 mvpMatrix;
in vec4 vVertex;
in vec2 vTexture;

out vec2 g_Tex;

void main(void)
{
	g_Tex = vTexture;
	gl_Position = mvpMatrix * vVertex;
}