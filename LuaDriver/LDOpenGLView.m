//
//  LDOpenGLView.m
//  LuaDriver
//
//  Created by Middleware on 7/19/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDOpenGLView.h"
#import "LDUtilities.h"
#import "LDViewFuncs.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"

#import "OpenGL/gl3.h"



@implementation LDOpenGLView




extern const char* k_userData;
extern struct lua_State* g_L;



static int ld_opengl_view_super_draw_rect(lua_State* L);



static const luaL_Reg LDOpenGLViewMetatable[] = {
	{ "superDrawRect", ld_opengl_view_super_draw_rect },
	{ "getFrame", ld_view_get_frame },
	{ NULL, NULL },
};




- (void)dealloc
{
	[self createUserData:g_L];
	
	lua_rawgeti(g_L, LUA_REGISTRYINDEX, _userDataRef);
	lua_getglobal(g_L, "LDOpenGLView");
	lua_getfield(g_L, -1, "dealloc");	/* func */
	lua_remove(g_L, -2);
	lua_pushvalue(g_L, -2);				/* this */
	lua_call(g_L, 1, 0);
	
	luaL_unref(g_L, LUA_REGISTRYINDEX, _userDataRef);
	[super dealloc];
}




- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_userDataRef = 0;
		
		NSOpenGLPixelFormatAttribute attributes [] = {
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
			0
		};
		
		NSOpenGLPixelFormat *pixelFormat = [[NSOpenGLPixelFormat alloc]
											initWithAttributes:attributes];
		[self setPixelFormat:pixelFormat];
		[pixelFormat release];
	}
	return self;
}





- (void)createUserData:(struct lua_State*)L
{
	if (_userDataRef)
		return;
	
	_userDataRef = [LDUtilities newLuaObject:L fromObject:self];
	
	[LDUtilities prepMetatable:L name:@"LDOpenGLView" gcmt:nil];
	
	lua_getglobal(L, "LDOpenGLView");
	luaL_setfuncs(L, LDOpenGLViewMetatable, 0);
	lua_setmetatable(L, -2);
	
	lua_pop(L, 2);
}





- (void)superDrawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}





- (void)prepareOpenGL
{
	[self createUserData:g_L];
	
	lua_rawgeti(g_L, LUA_REGISTRYINDEX, _userDataRef);
	lua_getglobal(g_L, "LDOpenGLView");
	lua_getfield(g_L, -1, "prepareOpenGL");				// funcs
	lua_remove(g_L, -2);
	lua_pushvalue(g_L, -2);								// "this"
	
	lua_call(g_L, 1, 0);
	
	GLint loc = glGetAttribLocation(3, "vVertex");
	GLint err = glGetError();
	NSLog(@"%d, %d", loc, err);
}






- (void)drawRect:(NSRect)dirtyRect
{
	[self createUserData:g_L];
	
	lua_rawgeti(g_L, LUA_REGISTRYINDEX, _userDataRef);
	
	lua_getglobal(g_L, "LDOpenGLView");
	lua_getfield(g_L, -1, "drawRect");					// funcs
	lua_remove(g_L, -2);
	lua_pushvalue(g_L, -2);								// "this"
	[LDUtilities newLuaObject:g_L fromRect:dirtyRect];  // rect
	
	lua_call(g_L, 2, 0);
	
	glSwapAPPLE();
}




- (void)setFrame:(NSRect)frameRect
{
	[self createUserData:g_L];
	
	lua_rawgeti(g_L, LUA_REGISTRYINDEX, _userDataRef);
	
	lua_getglobal(g_L, "LDOpenGLView");
	lua_getfield(g_L, -1, "setFrame");					// funcs
	lua_remove(g_L, -2);
	lua_pushvalue(g_L, -2);								// "this"
	[LDUtilities newLuaObject:g_L fromRect:frameRect];  // rect
	
	lua_call(g_L, 2, 0);
	
	[super setFrame:frameRect];
}




- (BOOL)acceptsFirstResponder
{
	return YES;
}





- (void)keyDown:(NSEvent *)theEvent
{
	char key = [[theEvent characters] characterAtIndex:0];
	
	NSLog(@"%c", key);
}




static int ld_opengl_view_super_draw_rect(lua_State* L)
{
	LDOpenGLView* openglView = [LDUtilities userDataFromLuaTable:L atIndex:1];
	NSRect rect = [LDUtilities nsRectFromLuaObject:L atIndex:2];
	lua_pop(L, 2);
	
	[openglView superDrawRect:rect];
	
	return 0;
}



@end
