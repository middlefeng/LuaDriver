//
//  LDOpenGL.m
//  LuaDriver
//
//  Created by Middleware on 7/19/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDOpenGL.h"
#import "LDUtilities.h"

#import "OpenGL/gl3.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"


static GLenum ld_opengl_name_to_enum(const char** names,
									 const GLenum* enums,
									 const char* name);



static int ld_opengl_genVertexArrays(lua_State*);
static int ld_opengl_deleteVertexArrays(lua_State*);
static int ld_opengl_bindVertexArray(lua_State*);
static int ld_opengl_enableVertexAttribArray(lua_State*);
static int ld_opengl_disableVertexAttribArray(lua_State*);
static int ld_opengl_getAttribLocation(lua_State*);
static int ld_opengl_vertexAttribPointer(lua_State*);

static int ld_opengl_genBuffers(lua_State*);
static int ld_opengl_deleteBuffers(lua_State*);
static int ld_opengl_bindBuffer(lua_State*);
static int ld_opengl_bufferData(lua_State*);
static int ld_opengl_bufferSubData(lua_State*);

static int ld_opengl_createProgram(lua_State*);
static int ld_opengl_deleteProgram(lua_State*);
static int ld_opengl_linkProgram(lua_State*);
static int ld_opengl_validateProgram(lua_State*);
static int ld_opengl_useProgram(lua_State*);
static int ld_opengl_createShader(lua_State*);
static int ld_opengl_deleteShader(lua_State*);
static int ld_opengl_shaderSource(lua_State*);
static int ld_opengl_compileShader(lua_State*);
static int ld_opengl_attachShader(lua_State*);
static int ld_opengl_getUniformLocation(lua_State*);
static int ld_opengl_uniformMatrix(lua_State*);
static int ld_opengl_uniform1i(lua_State*);
static int ld_opengl_uniform(lua_State*);

static int ld_opengl_activeTexture(lua_State*);
static int ld_opengl_genTextures(lua_State*);
static int ld_opengl_deleteTextures(lua_State*);
static int ld_opengl_bindTexture(lua_State*);
static int ld_opengl_texImage2D(lua_State*);
static int ld_opengl_texParameter(lua_State*);

static int ld_opengl_getError(lua_State*);
static int ld_opengl_enable(lua_State*);
static int ld_opengl_disable(lua_State*);
static int ld_opengl_lineWidth(lua_State*);
static int ld_opengl_polygonMode(lua_State*);
static int ld_opengl_polygonOffset(lua_State*);
static int ld_opengl_blendFunc(lua_State*);
static int ld_opengl_clearColor(lua_State*);
static int ld_opengl_clear(lua_State*);
static int ld_opengl_viewPort(lua_State*);
static int ld_opengl_drawArrays(lua_State*);
static int ld_opengl_drawElements(lua_State*);



static const luaL_Reg LDOpenGLFuncs[] = {
	{ "genVertexArrays", ld_opengl_genVertexArrays },
	{ "deleteVertexArrays", ld_opengl_deleteVertexArrays },
	{ "bindVertexArray", ld_opengl_bindVertexArray },
	{ "enableVertexAttribArray", ld_opengl_enableVertexAttribArray },
	{ "disableVertexAttribArray", ld_opengl_disableVertexAttribArray },
	{ "getAttribLocation", ld_opengl_getAttribLocation },
	{ "vertexAttribPointer", ld_opengl_vertexAttribPointer },

	{ "genBuffers", ld_opengl_genBuffers },
	{ "deleteBuffers", ld_opengl_deleteBuffers },
	{ "bindBuffer", ld_opengl_bindBuffer },
	{ "bufferData", ld_opengl_bufferData },
	{ "bufferSubData", ld_opengl_bufferSubData },
	
	{ "createProgram", ld_opengl_createProgram },
	{ "deleteProgram", ld_opengl_deleteProgram },
	{ "linkProgram", ld_opengl_linkProgram },
	{ "validateProgram", ld_opengl_validateProgram },
	{ "useProgram", ld_opengl_useProgram },
	{ "createShader", ld_opengl_createShader },
	{ "deleteShader", ld_opengl_deleteShader },
	{ "shaderSource", ld_opengl_shaderSource },
	{ "compileShader", ld_opengl_compileShader },
	{ "attachShader", ld_opengl_attachShader },
	{ "getUniformLocation", ld_opengl_getUniformLocation },
	{ "uniformMatrix", ld_opengl_uniformMatrix },
	{ "uniform1i", ld_opengl_uniform1i },
	{ "uniform", ld_opengl_uniform },
	
	{ "activeTexture", ld_opengl_activeTexture },
	{ "genTextures", ld_opengl_genTextures },
	{ "deleteTextures", ld_opengl_deleteTextures },
	{ "bindTexture", ld_opengl_bindTexture },
	{ "texImage2D", ld_opengl_texImage2D },
	{ "texParameter", ld_opengl_texParameter },

	{ "getError", ld_opengl_getError },
	{ "enable", ld_opengl_enable },
	{ "disable", ld_opengl_disable },
	{ "lineWidth", ld_opengl_lineWidth },
	{ "polygonMode", ld_opengl_polygonMode },
	{ "polygonOffset", ld_opengl_polygonOffset },
	{ "blendFunc", ld_opengl_blendFunc },
	{ "clearColor", ld_opengl_clearColor },
	{ "clear", ld_opengl_clear },
	{ "viewPort", ld_opengl_viewPort },
	{ "drawArrays", ld_opengl_drawArrays },
	{ "drawElements", ld_opengl_drawElements },

	{ NULL, NULL }
};



extern void init_LDOpenGL(struct lua_State* L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "NSOpenGL");
	luaL_setfuncs(L, LDOpenGLFuncs, 0);
	lua_pop(L, 1);
}




static int ld_opengl_genVertexArrays(lua_State* L)
{
	int number = (int)lua_tointeger(L, 1);
	lua_pop(L, 1);
	
	GLuint* arrays = malloc(sizeof(GLuint) * number);
	glGenVertexArrays((GLsizei)number, arrays);
	
	for (long i = 0; i < number; ++i)
		lua_pushinteger(L, arrays[i]);
	
	free(arrays);
	return number;
}




static int ld_opengl_deleteVertexArrays(lua_State* L)
{
	size_t size = lua_gettop(L);
	GLuint* arrays = malloc(sizeof(GLuint) * size);
	
	for (size_t i = 0; i < size; ++i)
		arrays[i] = lua_tounsigned(L, (int)(i + 1));
	lua_pop(L, lua_gettop(L));
	
	glDeleteVertexArrays((GLuint)size, arrays);
	
	free(arrays);
	return 0;
}




static int ld_opengl_bindVertexArray(lua_State* L)
{
	GLuint vertexArray = luaL_checkunsigned(L, 1);
	lua_pop(L, 1);
	glBindVertexArray(vertexArray);
	return 0;
}




static int ld_opengl_enableVertexAttribArray(lua_State* L)
{
	GLuint attribLocation = lua_tounsigned(L, 1);
	lua_pop(L, 1);
	glEnableVertexAttribArray(attribLocation);
	return 0;
}




static int ld_opengl_disableVertexAttribArray(lua_State* L)
{
	GLuint attribLocation = lua_tounsigned(L, 1);
	lua_pop(L, 1);
	glDisableVertexAttribArray(attribLocation);
	return 0;
}



static int ld_opengl_lineWidth(lua_State* L)
{
	GLfloat width = luaL_checknumber(L, 1);
	lua_pop(L, 1);
	glLineWidth(width);
	return 0;
}




static int ld_opengl_getAttribLocation(lua_State* L)
{
	GLuint program = luaL_checkunsigned(L, 1);
	const char* name = luaL_checkstring(L, 2);
	
	GLint location = glGetAttribLocation(program, name);

	lua_pop(L, 2);
	lua_pushinteger(L, location);
	return 1;
}




static const char* sVertexAttribTypeNames[] = {
	"GL_BYTE", "GL_UNSIGNED_BYTE", "GL_SHORT", "GL_UNSIGNED_SHORT",
	"GL_INT", "GL_UNSIGNED_INT", "GL_HALF_FLOAT",
	"GL_FLOAT", "GL_DOUBLE", 0
};

static const GLenum sVertexAttribTypes[] = {
	GL_BYTE, GL_UNSIGNED_BYTE, GL_SHORT, GL_UNSIGNED_SHORT,
	GL_INT, GL_UNSIGNED_INT, GL_HALF_FLOAT, GL_FLOAT, GL_DOUBLE
};

static int ld_opengl_vertexAttribPointer(lua_State* L)
{
	GLuint index = lua_tounsigned(L, 1);
	GLint size = (GLint)lua_tointeger(L, 2);
	
	const char* typeName = lua_tostring(L, 3);
	GLenum type = ld_opengl_name_to_enum(sVertexAttribTypeNames,
										 sVertexAttribTypes, typeName);
	
	
	bool normalized = lua_toboolean(L, 4);
	GLsizei stride = 0;
	void* pointer = 0;
	if (lua_gettop(L) > 4) {
		stride = (GLsizei)lua_tointeger(L, 5);
		pointer = (void*)lua_tointeger(L, 6);
	}
	
	lua_pop(L, lua_gettop(L));
	glVertexAttribPointer(index, size, type, normalized, stride, pointer);
	return 0;
}




static int ld_opengl_genBuffers(lua_State* L)
{
	GLsizei size = (GLsizei)lua_tointeger(L, 1);
	lua_pop(L, 1);
	
	GLuint* buffers = malloc(sizeof(GLuint) * size);
	glGenBuffers(size, buffers);
	
	for (GLsizei i = 0; i < size; ++i)
		lua_pushinteger(L, buffers[i]);
	
	free(buffers);
	return size;
}




static int ld_opengl_deleteBuffers(lua_State* L)
{
	size_t size = lua_gettop(L);
	GLuint* buffers = malloc(sizeof(GLuint) * size);
	
	for (size_t i = 0; i < size; ++i)
		buffers[i] = lua_tounsigned(L, (int)(i + 1));
	lua_pop(L, lua_gettop(L));
	
	glDeleteBuffers((GLuint)size, buffers);
	
	free(buffers);
	return 0;
}




static const char* sBufferTargetNames[] = {
	"GL_ARRAY_BUFFER", "GL_COPY_READ_BUFFER",
	"GL_COPY_WRITE_BUFFER", "GL_ELEMENT_ARRAY_BUFFER",
	"GL_PIXEL_PACK_BUFFER", "GL_PIXEL_UNPACK_BUFFER",
	"GL_TEXTURE_BUFFER", "GL_TRANSFORM_FEEDBACK_BUFFER",
	"GL_UNIFORM_BUFFER", 0 };

static const GLenum sBufferTargetEnum[] = {
	GL_ARRAY_BUFFER, GL_COPY_READ_BUFFER, GL_COPY_WRITE_BUFFER,
	GL_ELEMENT_ARRAY_BUFFER, GL_PIXEL_PACK_BUFFER,
	GL_PIXEL_UNPACK_BUFFER, GL_TEXTURE_BUFFER,
	GL_TRANSFORM_FEEDBACK_BUFFER, GL_UNIFORM_BUFFER };

static const char* sBufferUsageNames[] = {
	"GL_STREAM_DRAW", "GL_STREAM_READ", "GL_STREAM_COPY",
	"GL_STATIC_DRAW", "GL_STATIC_READ", "GL_STATIC_COPY",
	"GL_DYNAMIC_DRAW", "GL_DYNAMIC_READ", "GL_DYNAMIC_COPY", 0
};


static const GLenum sBufferUsages[] = {
	GL_STREAM_DRAW, GL_STREAM_READ, GL_STREAM_COPY,
	GL_STATIC_DRAW, GL_STATIC_READ, GL_STATIC_COPY,
	GL_DYNAMIC_DRAW, GL_DYNAMIC_READ, GL_DYNAMIC_COPY };


static int ld_opengl_bindBuffer(lua_State* L)
{
	const char* targetName = lua_tostring(L, 1);
	GLuint buffer = lua_tounsigned(L, 2);
	
	GLenum target = ld_opengl_name_to_enum(sBufferTargetNames,
										   sBufferTargetEnum, targetName);
	
	lua_pop(L, 2);
	glBindBuffer(target, buffer);
	return 0;
}



static int ld_opengl_bufferData(lua_State* L)
{
	const char* targetName = luaL_checkstring(L, 1);
	const char* type = luaL_checkstring(L, 2);
	
	lua_len(L, 3);
	size_t bufferSize = lua_tounsigned(L, -1);
	lua_rawgeti(L, 3, 1);
	size_t elementCount = [LDUtilities luaTableKeyCount:L at:-1];
	lua_pop(L, 2);
	
	const char* usageName = lua_tostring(L, 4);
	
	GLenum target = ld_opengl_name_to_enum(sBufferTargetNames,
										   sBufferTargetEnum, targetName);
	GLenum usage = ld_opengl_name_to_enum(sBufferUsageNames,
										  sBufferUsages, usageName);

	void* buffer = 0;
	size_t elementSize = 0;
	if (strcmp(type, "GL_FLOAT") == 0)
		elementSize = sizeof(GLfloat);
	else if (strcmp(type, "GL_UNSIGNED_SHORT") == 0)
		elementSize = sizeof(GLushort);
	else if (strcmp(type, "GL_SHORT") == 0)
		elementSize = sizeof(GLshort);

	buffer = malloc(elementSize * bufferSize * elementCount);
	for (size_t i = 0; i < bufferSize; ++i) {
		lua_rawgeti(L, 3, (int)(i + 1));
		for (size_t e = 0; e < elementCount; ++e) {
			lua_rawgeti(L, -1, (int)(e + 1));
			if (strcmp(type, "GL_FLOAT") == 0) {
				((GLfloat*)buffer)[i * elementCount + e] = (GLfloat)luaL_checknumber(L, -1);
			} else if (strcmp(type, "GL_UNSIGNED_SHORT") == 0) {
				((GLushort*)buffer)[i * elementCount + e] = (GLushort)luaL_checkunsigned(L, -1);
			} else if (strcmp(type, "GL_SHORT") == 0) {
				((GLshort*)buffer)[i * elementCount + e] = (GLshort)luaL_checkinteger(L, -1);
			}
			lua_pop(L, 1);
		}
		lua_pop(L, 1);
	}
	
	lua_pop(L, 4);
	
	glBufferData(target, elementSize * bufferSize * elementCount, buffer, usage);
	free(buffer);
	
	return 0;
}




static int ld_opengl_bufferSubData(lua_State* L)
{
	const char* targetName = lua_tostring(L, 1);
	GLintptr offset = (GLintptr)lua_tointeger(L, 2);
	const char* type = lua_tostring(L, 3);
	
	lua_len(L, 4);
	size_t bufferSize = lua_tounsigned(L, -1);
	lua_pop(L, 1);
	
	GLenum target = ld_opengl_name_to_enum(sBufferTargetNames,
										   sBufferTargetEnum, targetName);

	void* buffer = 0;
	size_t elementSize = 0;
	if (strcmp(type, "float") == 0)
		elementSize = sizeof(GLfloat);
	
	buffer = malloc(elementSize * bufferSize);
	for (size_t i = 0; i < bufferSize; ++i) {
		lua_rawgeti(L, 4, (int)(i + 1));
		if (strcmp(type, "float") == 0)
			((GLfloat*)buffer)[i] = lua_tonumber(L, -1);
		lua_pop(L, 1);
	}
	
	lua_pop(L, 4);
	
	glBufferSubData(target, offset, elementSize * bufferSize, buffer);
	free(buffer);
	
	return 0;
}




static int ld_opengl_createProgram(lua_State* L)
{
	GLuint program = glCreateProgram();
	lua_pushinteger(L, program);
	return 1;
}




static int ld_opengl_deleteProgram(lua_State* L)
{
	GLuint program = (GLuint)lua_tounsigned(L, 1);
	lua_pop(L, 1);
	glDeleteProgram(program);
	return 0;
}





static int ld_opengl_linkProgram(lua_State* L)
{
	GLuint program = (GLuint)lua_tounsigned(L, 1);
	lua_pop(L, 1);
	glLinkProgram(program);
	return 0;
}




static int ld_opengl_validateProgram(lua_State* L)
{
	GLuint program = (GLuint)lua_tounsigned(L, 1);
	lua_pop(L, 1);
	glValidateProgram(program);
	
	GLint validState = 0;
	glGetProgramiv(program, GL_VALIDATE_STATUS, &validState);
	
	if (validState != GL_TRUE) {
		GLint logLength = 0;
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
		
		char* log = malloc(sizeof(char) * (logLength + 1));
		glGetProgramInfoLog(program, logLength, &validState, log);
		
		lua_pushstring(L, log);
		free(log);
		return 1;
	}
	
	return 0;
}




static int ld_opengl_useProgram(lua_State* L)
{
	GLuint program = (GLuint)lua_tounsigned(L, 1);
	lua_pop(L, 1);
 	glUseProgram(program);

	return 0;
}




static int ld_opengl_createShader(lua_State* L)
{
	const char* type = lua_tostring(L, 1);
	GLenum typeEnum = GL_VERTEX_SHADER;
	if (strcmp(type, "GL_VERTEX_SHADER") == 0)
		typeEnum = GL_VERTEX_SHADER;
	else if (strcmp(type, "GL_FRAGMENT_SHADER") == 0)
		typeEnum = GL_FRAGMENT_SHADER;
	
	lua_pop(L, 1);
	
	GLuint shader = glCreateShader(typeEnum);
	
	lua_pushinteger(L, shader);
	return 1;
}



static int ld_opengl_deleteShader(lua_State* L)
{
	GLuint shader = (GLuint)lua_tounsigned(L, 1);
	lua_pop(L, 1);
	glDeleteShader(shader);
	return 0;
}




static int ld_opengl_shaderSource(lua_State* L)
{
	GLuint shader = (GLuint)lua_tointeger(L, 1);
	
	int sourceNumber = lua_gettop(L) - 1;
	const char** sources = malloc(sizeof(char*) * sourceNumber);
	for (int i = 0; i < sourceNumber; ++i) {
		sources[i] = lua_tostring(L, i + 2);
	}
	
	glShaderSource(shader, sourceNumber, (const GLchar**)sources, 0);
	lua_pop(L, sourceNumber + 1);
	
	return 0;
}





static int ld_opengl_compileShader(lua_State* L)
{
	GLuint shader = (GLuint)lua_tointeger(L, 1);
	lua_pop(L, 1);
	
	glCompileShader(shader);
	
	GLint compileState = 0;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &compileState);
	
	if (compileState != GL_TRUE) {
		GLint logLength = 0;
		glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logLength);
		
		char* log = malloc(sizeof(char) * (logLength + 1));
		glGetShaderInfoLog(shader, logLength, &compileState, log);
		
		lua_pushstring(L, log);
		free(log);
		return 1;
	}
	
	return 0;
}




static int ld_opengl_attachShader(lua_State* L)
{
	GLuint program = (GLuint)luaL_checkunsigned(L, 1);
	GLuint shader = (GLuint)luaL_checkunsigned(L, 2);
	lua_pop(L, 2);
	
	glAttachShader(program, shader);
	
	return 0;
}




static int ld_opengl_getUniformLocation(lua_State* L)
{
	GLuint program = (GLuint)luaL_checkunsigned(L, 1);
	const char* name = luaL_checkstring(L, 2);
	lua_pop(L, 2);
	
	GLint loc = glGetUniformLocation(program, name);
	lua_pushinteger(L, loc);
	return 1;
}



static int ld_opengl_uniformMatrix(lua_State* L)
{
	GLint loc = (GLint)luaL_checkinteger(L, 1);
	bool transpose = lua_toboolean(L, 2);
	
	lua_len(L, 3);
	unsigned int size = lua_tounsigned(L, -1);
	lua_pop(L, 1);
	
	int count = lua_gettop(L) - 2;
	
	if (size == 16) {
		GLfloat* matrix = malloc(sizeof(GLfloat) * 16 * count);
		for (size_t i = 0; i < count; ++i) {
			for (size_t j = 0; j < 16; ++j) {
				lua_rawgeti(L, (int)(i + 3), (int)(j + 1));
				matrix[i * 16 + j] = lua_tonumber(L, -1);
				lua_pop(L, 1);
			}
		}
		
		glUniformMatrix4fv(loc, count, transpose, matrix);
		free(matrix);
	}
	
	lua_pop(L, lua_gettop(L));
	
	return 0;
}



static int ld_opengl_uniform1i(lua_State* L)
{
	GLint loc = (GLint)luaL_checkinteger(L, 1);
	GLint v0 = (GLint)luaL_checkinteger(L, 2);
	lua_pop(L, 2);

	glUniform1i(loc, v0);
	return 0;
}



static int ld_opengl_uniform(lua_State* L)
{
	GLint loc = (GLint)luaL_checkinteger(L, 1);
	GLsizei count = lua_gettop(L) - 1;
	
	lua_len(L, 2);
	unsigned int size = lua_tounsigned(L, -1);
	lua_pop(L, 1);
	
	if (size == 4) {
		GLfloat* value = malloc(size * count * sizeof(GLfloat));
		for (size_t i = 0; i < count; ++i) {
			for (size_t j = 0; j < 4; ++j) {
				lua_rawgeti(L, (int)(i + 2), (int)(j + 1));
				value[i * 4 + j] = luaL_checknumber(L, -1);
				lua_pop(L, 1);
			}
		}
		glUniform4fv(loc, count, value);
		free(value);
	}
	
	lua_pop(L, lua_gettop(L));
	return 0;
}




static const char* sGLEnableNames[] = {
	"GL_BLEND", "GL_DEPTH_TEST", "GL_LINE_SMOOTH",
	"GL_POLYGON_OFFSET_LINE",
	"GL_TEXTURE_1D", "GL_TEXTURE_2D", "GL_TEXTURE_3D",
	"GL_TEXTURE_GEN_Q", "GL_TEXTURE_GEN_R", "GL_TEXTURE_GEN_S",
	"GL_TEXTURE_GEN_T", 0
};

static const GLenum sGLEnables[] = {
	GL_BLEND, GL_DEPTH_TEST, GL_LINE_SMOOTH,
	GL_POLYGON_OFFSET_LINE,
	GL_TEXTURE_1D, GL_TEXTURE_2D, GL_TEXTURE_3D,
	GL_TEXTURE_GEN_Q, GL_TEXTURE_GEN_R, GL_TEXTURE_GEN_S,
	GL_TEXTURE_GEN_T, 0
};


static int ld_opengl_enable(lua_State* L)
{
	const char* enable = luaL_checkstring(L, 1);
	GLenum enableEnum = ld_opengl_name_to_enum(sGLEnableNames,
											   sGLEnables, enable);

	lua_pop(L, 1);
	glEnable(enableEnum);
	return 0;
}




static int ld_opengl_disable(lua_State* L)
{
	const char* enable = luaL_checkstring(L, 1);
	GLenum enableEnum = ld_opengl_name_to_enum(sGLEnableNames,
											   sGLEnables, enable);
	
	lua_pop(L, 1);
	glDisable(enableEnum);
	return 0;
}




static const char* sPolygonFaceNames[] = {
	"GL_FRONT", "GL_BACK", "GL_FRONT_AND_BACK", 0
};

static const GLenum sPolygonFaces[] = {
	GL_FRONT, GL_BACK, GL_FRONT_AND_BACK
};

static const char* sPolygonModeNames[] = {
	"GL_POINT", "GL_LINE", "GL_FILL", 0
};

static const GLenum sPolygonModes[] = {
	GL_POINT, GL_LINE, GL_FILL
};



static int ld_opengl_polygonMode(lua_State* L)
{
	const char* faceName = luaL_checkstring(L, 1);
	const char* modeName = luaL_checkstring(L, 2);
	
	GLenum face = ld_opengl_name_to_enum(sPolygonFaceNames,
										 sPolygonFaces, faceName);
	GLenum mode = ld_opengl_name_to_enum(sPolygonModeNames,
										 sPolygonModes, modeName);
	
	lua_pop(L, 2);
	glPolygonMode(face, mode);
	return 0;
}




static int ld_opengl_polygonOffset(lua_State* L)
{
	GLfloat factor = luaL_checknumber(L, 1);
	GLfloat units = luaL_checknumber(L, 2);
	lua_pop(L, 2);
	
	glPolygonOffset(factor, units);
	return 0;
}



static const char* sBlendFuncNames[] = {
	"GL_ZERO", "GL_ONE", "GL_DST_COLOR", "GL_ONE_MINUS_DST_COLOR", "GL_SRC_ALPHA",
	"GL_ONE_MINUS_SRC_ALPHA", "GL_DST_ALPHA", "GL_ONE_MINUS_DST_ALPHA",
	"GL_SRC_ALPHA_SATURATE", "GL_CONSTANT_COLOR", "GL_ONE_MINUS_CONSTANT_COLOR",
	"GL_CONSTANT_ALPHA", "GL_ONE_MINUS_CONSTANT_ALPHA", "GL_SRC_COLOR",
	"GL_ONE_MINUS_SRC_COLOR", 0
};

static const GLenum sBlendFuncs[] = {
	GL_ZERO, GL_ONE, GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA,
	GL_ONE_MINUS_SRC_ALPHA, GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA,
	GL_SRC_ALPHA_SATURATE, GL_CONSTANT_COLOR, GL_ONE_MINUS_CONSTANT_COLOR,
	GL_CONSTANT_ALPHA, GL_ONE_MINUS_CONSTANT_ALPHA, GL_SRC_COLOR,
	GL_ONE_MINUS_SRC_COLOR
};

static int ld_opengl_blendFunc(lua_State* L)
{
	const char* sfactorName = luaL_checkstring(L, 1);
	const char* dfactorName = luaL_checkstring(L, 2);
	GLenum sfactor = ld_opengl_name_to_enum(sBlendFuncNames,
											sBlendFuncs, sfactorName);
	GLenum dfactor = ld_opengl_name_to_enum(sBlendFuncNames,
											sBlendFuncs, dfactorName);
	
	lua_pop(L, 2);
	glBlendFunc(sfactor, dfactor);
	return 0;
}




static int ld_opengl_activeTexture(lua_State* L)
{
	unsigned int i = luaL_checkunsigned(L, 1);
	lua_pop(L, 1);
	
	GLenum activated = GL_TEXTURE0 + i;
	glActiveTexture(activated);
	return 0;
}



const char* sInternalFormatNames[] = {
	"GL_ALPHA", "GL_ALPHA4", "GL_ALPHA8, GL_ALPHA12", "GL_ALPHA16",
    "GL_LUMINANCE", "GL_LUMINANCE4", "GL_LUMINANCE8", "GL_LUMINANCE12",
	"GL_LUMINANCE16", "GL_LUMINANCE_ALPHA", "GL_LUMINANCE4_ALPHA4",
	"GL_LUMINANCE6_ALPHA2", "GL_LUMINANCE8_ALPHA8", "GL_LUMINANCE12_ALPHA4",
	"GL_LUMINANCE12_ALPHA12", "GL_LUMINANCE16_ALPHA16", "GL_INTENSITY",
	"GL_INTENSITY4", "GL_INTENSITY8", "GL_INTENSITY12", "GL_INTENSITY16",
	"GL_R3_G3_B2", "GL_RGB", "GL_RGB4", "GL_RGB5", "GL_RGB8", "GL_RGB10",
	"GL_RGB12", "GL_RGB16", "GL_RGBA", "GL_RGBA2", "GL_RGBA4", "GL_RGB5_A1",
	"GL_RGBA8", "GL_RGB10_A2", "GL_RGBA12", "GL_RGBA16", 0
};

const GLenum sInternalFormats[] = {
	GL_ALPHA, GL_ALPHA4, GL_ALPHA8, GL_ALPHA12,
	GL_ALPHA16, GL_LUMINANCE, GL_LUMINANCE4, GL_LUMINANCE8, GL_LUMINANCE12,
	GL_LUMINANCE16, GL_LUMINANCE_ALPHA, GL_LUMINANCE4_ALPHA4, GL_LUMINANCE6_ALPHA2,
	GL_LUMINANCE8_ALPHA8, GL_LUMINANCE12_ALPHA4, GL_LUMINANCE12_ALPHA12,
	GL_LUMINANCE16_ALPHA16, GL_INTENSITY, GL_INTENSITY4, GL_INTENSITY8, GL_INTENSITY12,
	GL_INTENSITY16, GL_R3_G3_B2, GL_RGB, GL_RGB4, GL_RGB5, GL_RGB8, GL_RGB10, GL_RGB12,
	GL_RGB16, GL_RGBA, GL_RGBA2, GL_RGBA4, GL_RGB5_A1, GL_RGBA8, GL_RGB10_A2, GL_RGBA12,
	GL_RGBA16
};

const char* sPixelFormatNames[] = {
	"GL_COLOR_INDEX", "GL_RED", "GL_GREEN", "GL_BLUE", "GL_ALPHA", "GL_RGB",
	"GL_BGR", "GL_RGBA", "GL_BGRA", "GL_LUMINANCE", "GL_LUMINANCE_ALPHA", 0
};

const GLenum sPixelFormats[] = {
	GL_COLOR_INDEX, GL_RED, GL_GREEN, GL_BLUE, GL_ALPHA, GL_RGB, GL_BGR, GL_RGBA, GL_BGRA,
	GL_LUMINANCE, GL_LUMINANCE_ALPHA
};

const char* sPixelTypeNames[] = {
	"GL_UNSIGNED_BYTE", "GL_BYTE", "GL_BITMAP", "GL_UNSIGNED_SHORT", "GL_SHORT",
	"GL_UNSIGNED_INT", "GL_INT", "GL_FLOAT", "GL_UNSIGNED_BYTE_3_3_2",
	"GL_UNSIGNED_BYTE_2_3_3_REV", "GL_UNSIGNED_SHORT_5_6_5", "GL_UNSIGNED_SHORT_5_6_5_REV",
	"GL_UNSIGNED_SHORT_4_4_4_4", "GL_UNSIGNED_SHORT_4_4_4_4_REV", "GL_UNSIGNED_SHORT_5_5_5_1",
	"GL_UNSIGNED_SHORT_1_5_5_5_REV", "GL_UNSIGNED_INT_8_8_8_8", "GL_UNSIGNED_INT_8_8_8_8_REV",
	"GL_UNSIGNED_INT_10_10_10_2", "GL_UNSIGNED_INT_2_10_10_10_REV", 0
};

const GLenum sPixelTypes[] = {
	GL_UNSIGNED_BYTE, GL_BYTE, GL_BITMAP, GL_UNSIGNED_SHORT, GL_SHORT,
	GL_UNSIGNED_INT, GL_INT, GL_FLOAT, GL_UNSIGNED_BYTE_3_3_2,
	GL_UNSIGNED_BYTE_2_3_3_REV, GL_UNSIGNED_SHORT_5_6_5, GL_UNSIGNED_SHORT_5_6_5_REV,
	GL_UNSIGNED_SHORT_4_4_4_4, GL_UNSIGNED_SHORT_4_4_4_4_REV, GL_UNSIGNED_SHORT_5_5_5_1,
	GL_UNSIGNED_SHORT_1_5_5_5_REV,  GL_UNSIGNED_INT_8_8_8_8, GL_UNSIGNED_INT_8_8_8_8_REV,
	GL_UNSIGNED_INT_10_10_10_2, GL_UNSIGNED_INT_2_10_10_10_REV
};

const char* sTargetNames[] = {
	"GL_TEXTURE_1D",
	"GL_TEXTURE_2D",
	"GL_TEXTURE_3D",
	"GL_PROXY_TEXTURE_1D",
	"GL_PROXY_TEXTURE_2D",
	"GL_PROXY_TEXTURE_3D", 0
};

const GLenum sTargets[] = {
	GL_TEXTURE_1D,
	GL_TEXTURE_2D,
	GL_TEXTURE_3D,
	GL_PROXY_TEXTURE_1D,
	GL_PROXY_TEXTURE_2D,
	GL_PROXY_TEXTURE_3D
};

static int ld_opengl_texImage2D(lua_State* L)
{
	const char* targetName = luaL_checkstring(L, 1);
	GLint level = (GLint)luaL_checkinteger(L, 2);
	const char* internalFormatName = luaL_checkstring(L, 3);
	GLint border = (GLint)luaL_checkinteger(L, 4);
	const char* formatName = luaL_checkstring(L, 5);
	const char* typeName = luaL_checkstring(L, 6);
	NSImage* image = [LDUtilities userDataFromLuaTable:L atIndex:7];
	
	GLenum target = ld_opengl_name_to_enum(sTargetNames, sTargets, targetName);
	GLenum internalFormat = ld_opengl_name_to_enum(sInternalFormatNames,
												   sInternalFormats,
												   internalFormatName);
	GLenum format = ld_opengl_name_to_enum(sPixelFormatNames,
										   sPixelFormats,
										   formatName);
	GLenum type = ld_opengl_name_to_enum(sPixelTypeNames,
										 sPixelTypes, typeName);
	
	
	NSBitmapImageRep* rep = [[image representations] objectAtIndex:0];
	void* bitmapData = [rep bitmapData];
	
	glTexImage2D(target, level, internalFormat,
				 (GLsizei)[rep pixelsWide], (GLsizei)[rep pixelsHigh],
				 border, format, type, bitmapData);
	
	lua_pop(L, 6);
	return 0;
}



static int ld_opengl_genTextures(lua_State* L)
{
	GLsizei size = (GLsizei)luaL_checkinteger(L, 1);
	lua_pop(L, 1);
	if (!size)
		return 0;
	
	GLuint* textures = malloc(sizeof(GLuint) * size);
	glGenTextures(size, textures);
	for (GLsizei i = 0; i < size; ++i)
		lua_pushunsigned(L, textures[i]);
	
	free(textures);
	return size;
}



static int ld_opengl_deleteTextures(lua_State* L)
{
	int count = lua_gettop(L);
	GLuint* textures = malloc(sizeof(GLuint) * count);
	for (int i = 0; i < count; ++i)
		textures[i] = luaL_checkunsigned(L, i + 1);
	
	lua_pop(L, lua_gettop(L));
	glDeleteTextures(count, textures);
	free(textures);
	return 0;
}



static int ld_opengl_bindTexture(lua_State* L)
{
	const char* name = luaL_checkstring(L, 1);
	GLuint texture = luaL_checkunsigned(L, 2);
	
	GLenum target = ld_opengl_name_to_enum(sTargetNames,
										   sTargets, name);
	lua_pop(L, 2);
	
	glBindTexture(target, texture);
	return 0;
}



static const char* sTexParamNames[] = {
	"GL_TEXTURE_MIN_FILTER", "GL_TEXTURE_MAG_FILTER", "GL_TEXTURE_MIN_LOD",
    "GL_TEXTURE_MAX_LOD", "GL_TEXTURE_BASE_LEVEL", "GL_TEXTURE_MAX_LEVEL",
	"GL_TEXTURE_WRAP_S", "GL_TEXTURE_WRAP_T", "GL_TEXTURE_WRAP_R",
	"GL_TEXTURE_BORDER_COLOR", "GL_TEXTURE_PRIORITY", 0
};

static const GLenum sTexParams[] = {
	GL_TEXTURE_MIN_FILTER, GL_TEXTURE_MAG_FILTER, GL_TEXTURE_MIN_LOD,
    GL_TEXTURE_MAX_LOD, GL_TEXTURE_BASE_LEVEL, GL_TEXTURE_MAX_LEVEL,
	GL_TEXTURE_WRAP_S, GL_TEXTURE_WRAP_T,
	GL_TEXTURE_WRAP_R, GL_TEXTURE_BORDER_COLOR, GL_TEXTURE_PRIORITY
};

static const char* sTexParamValueNames[] = {
	"GL_NEAREST", "GL_LINEAR", "GL_NEAREST_MIPMAP_NEAREST",
	"GL_LINEAR_MIPMAP_NEAREST", "GL_NEAREST_MIPMAP_LINEAR",
	"GL_LINEAR_MIPMAP_LINEAR", "GL_CLAMP", "GL_CLAMP_TO_EDGE",
	"GL_REPEAT", 0
};

static const GLenum sTexParamValues[] = {
	GL_NEAREST, GL_LINEAR, GL_NEAREST_MIPMAP_NEAREST,
	GL_LINEAR_MIPMAP_NEAREST, GL_NEAREST_MIPMAP_LINEAR,
	GL_LINEAR_MIPMAP_LINEAR, GL_CLAMP, GL_CLAMP_TO_EDGE,
	GL_REPEAT
};

static int ld_opengl_texParameter(lua_State* L)
{
	const char* targetName = luaL_checkstring(L, 1);
	const char* paramName = luaL_checkstring(L, 2);
	
	GLenum target = ld_opengl_name_to_enum(sTargetNames, sTargets, targetName);
	GLenum param = ld_opengl_name_to_enum(sTexParamNames, sTexParams, paramName);
	switch (param) {
		case GL_TEXTURE_MIN_LOD:
		case GL_TEXTURE_MAX_LOD:
		case GL_TEXTURE_BASE_LEVEL:
		case GL_TEXTURE_MAX_LEVEL:
		case GL_TEXTURE_PRIORITY: {
			GLfloat value = luaL_checknumber(L, 3);
			glTexParameterf(target, param, value);
			break;
		}
		default: {
			const char* valueName = luaL_checkstring(L, 3);
			GLenum value = ld_opengl_name_to_enum(sTexParamValueNames,
												  sTexParamValues, valueName);
			glTexParameterf(target, param, value);
		}
	}
	
	lua_pop(L, 3);
	return 0;
}




static int ld_opengl_getError(lua_State* L)
{
	GLenum e = glGetError();
	lua_pushinteger(L, e);
	return 1;
}




static int ld_opengl_clearColor(lua_State* L)
{
	GLfloat r = lua_tonumber(L, 1);
	GLfloat g = lua_tonumber(L, 2);
	GLfloat b = lua_tonumber(L, 3);
	GLfloat a = lua_tonumber(L, 4);
	lua_pop(L, 4);
	
	glClearColor(r, g, b, a);
	return 0;
}



static const char* sBufferBitNames[] = {
	"GL_COLOR_BUFFER_BIT", "GL_DEPTH_BUFFER_BIT",
	"GL_ACCUM_BUFFER_BIT", "GL_STENCIL_BUFFER_BIT", 0
};

static const GLbitfield sBufferBits[] = {
	GL_COLOR_BUFFER_BIT, GL_DEPTH_BUFFER_BIT,
	GL_ACCUM_BUFFER_BIT, GL_STENCIL_BUFFER_BIT
};



static int ld_opengl_clear(lua_State* L)
{
	int count = (int)lua_gettop(L);
	
	GLbitfield bufferBits = 0;
	for (int i = 0; i < count; ++i) {
		const char* bufferBitName = lua_tostring(L, i + 1);
		for (int j = 0; true; ++j) {
			const char* name = sBufferBitNames[j];
			if (!name)
				break;
			if (strcmp(name, bufferBitName) == 0) {
				bufferBits |= sBufferBits[j];
				break;
			}
		}
	}

	lua_pop(L, lua_gettop(L));
	glClear(bufferBits);
	return 0;
}



static int ld_opengl_viewPort(lua_State* L)
{
	GLint x = (GLint)lua_tointeger(L, 1);
	GLint y = (GLint)lua_tointeger(L, 2);
	GLsizei w = (GLsizei)lua_tointeger(L, 3);
	GLsizei h = (GLsizei)lua_tointeger(L, 4);
	lua_pop(L, 4);
	glViewport(x, y, w, h);
	return 0;
}



static const char* sDrawModeNames[] = {
	"GL_POINTS", "GL_LINE_STRIP", "GL_LINE_LOOP",  "GL_LINES",
	"GL_TRIANGLE_STRIP", "GL_TRIANGLE_FAN", "GL_TRIANGLES",
	"GL_QUAD_STRIP", "GL_QUADS", "GL_POLYGON", 0
};


static const GLenum sDrawModes[] = {
	GL_POINTS, GL_LINE_STRIP,
	GL_LINE_LOOP, GL_LINES, GL_TRIANGLE_STRIP, GL_TRIANGLE_FAN,
	GL_TRIANGLES, GL_QUAD_STRIP, GL_QUADS, GL_POLYGON };




static int ld_opengl_drawArrays(lua_State* L)
{
	const char* modeName = luaL_checkstring(L, 1);
	GLint first = (GLint)luaL_checkinteger(L, 2);
	GLsizei count = (GLsizei)luaL_checkinteger(L, 3);
	
	GLenum mode = ld_opengl_name_to_enum(sDrawModeNames,
										 sDrawModes, modeName);
	
	lua_pop(L, 3);
	glDrawArrays(mode, first, count);
	return 0;
}




static int ld_opengl_drawElements(lua_State* L)
{
	const char* modeName = luaL_checkstring(L, 1);
	GLsizei count = luaL_checkunsigned(L, 2);
	const char* typeName = luaL_checkstring(L, 3);
	
	GLenum type = ld_opengl_name_to_enum(sVertexAttribTypeNames,
										 sVertexAttribTypes, typeName);
	size_t elementSize = 0;
	if (type == GL_UNSIGNED_BYTE)
		elementSize = sizeof(GLubyte);
	else if (type == GL_UNSIGNED_SHORT)
		elementSize = sizeof(GLushort);
	else if (type == GL_UNSIGNED_INT)
		elementSize = sizeof(GLuint);
	
	GLvoid* indices = 0;
	if (lua_gettop(L) == 4 && lua_istable(L, 4))
		indices = malloc(elementSize * count);

	if (indices) {
		for (size_t i = 0; i < count; ++i) {
			lua_rawgeti(L, 4,(int)(i + 1));
			GLuint index = luaL_checkunsigned(L, -1);
			lua_pop(L, 1);
			
			if (type == GL_UNSIGNED_BYTE)
				((GLubyte*)indices)[i] = (GLubyte)index;
			else if (type == GL_UNSIGNED_SHORT)
				((GLushort*)indices)[i] = (GLushort)index;
			else if (type == GL_UNSIGNED_INT)
				((GLuint*)indices)[i] = index;
		}
	}
	
	GLenum mode = ld_opengl_name_to_enum(sDrawModeNames,
										 sDrawModes, modeName);
	
	lua_pop(L, lua_gettop(L));
	glDrawElements(mode, count, type, indices);
	if (indices)
		free(indices);
	return 0;
}





static GLenum ld_opengl_name_to_enum(const char** names,
									 const GLenum* enums,
									 const char* name)
{
	GLenum r = 0;
	for (size_t i = 0; true; ++i) {
		const char* optionName = names[i];
		if (!optionName)
			break;
		if (strcmp(optionName, name) == 0) {
			r = enums[i];
			break;
		}
	}
	
	return r;
}














