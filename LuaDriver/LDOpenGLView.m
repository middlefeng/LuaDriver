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
#import "LDEvent.h"
#import "LDMenu.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



@implementation LDOpenGLView




extern const char* k_userData;
extern struct lua_State* g_L;



static int ld_opengl_view_super_draw_rect(lua_State* L);



static const luaL_Reg LDOpenGLViewMetatable[] = {
	{ "superDrawRect", ld_opengl_view_super_draw_rect },
	{ "getFrame", ld_view_get_frame },
	{ "setNeedsDisplay", ld_view_set_needs_display },
	{ NULL, NULL },
};




- (void)dealloc
{
	[self createUserData:g_L];
	
	[LDUtilities prepCall:g_L onMethod:@"dealloc" onObject:self];
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
			NSOpenGLPFAAccelerated,
			NSOpenGLPFADoubleBuffer,
			NSOpenGLPFADepthSize, 32,
			NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core,
			0
		};
		
		[self setWantsBestResolutionOpenGLSurface:YES];
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
	
	[LDUtilities prepMetatable:L name:@"LDOpenGLView"];
	
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
	[LDUtilities prepCall:g_L onMethod:@"prepareOpenGL" onObject:self];
	lua_call(g_L, 1, 0);
}






- (void)drawRect:(NSRect)dirtyRect
{
	[self createUserData:g_L];
	[LDUtilities prepCall:g_L onMethod:@"drawRect" onObject:self];
	[LDUtilities newLuaObject:g_L fromRect:dirtyRect];  // rect
	
	lua_call(g_L, 2, 0);
	
	glSwapAPPLE();
}




- (void)setFrame:(NSRect)frameRect
{
	[self createUserData:g_L];
	
	[LDUtilities prepCall:g_L onMethod:@"setFrame" onObject:self];
	[LDUtilities newLuaObject:g_L fromRect:frameRect];
	
	lua_call(g_L, 2, 0);
	
	[super setFrame:frameRect];
}




- (BOOL)acceptsFirstResponder
{
	return YES;
}





- (void)keyDown:(NSEvent *)theEvent
{
	[self createUserData:g_L];
	
	[LDUtilities prepCall:g_L onMethod:@"keyDown" onObject:self];
	newLuaObjectOfEvent(g_L, theEvent);
	
	lua_call(g_L, 2, 0);
}




- (void)rightMouseDown:(NSEvent *)theEvent
{
	[self createUserData:g_L];
	
	[LDUtilities prepCall:g_L onMethod:@"rightMouseDown" onObject:self];
	newLuaObjectOfEvent(g_L, theEvent);
	
	lua_call(g_L, 2, 0);
	
	[super rightMouseDown:theEvent];
}




- (IBAction)drawObjectType:(id)sender
{
	NSMenuItem* item = sender;

	[self createUserData:g_L];
	
	[LDUtilities prepCall:g_L onMethod:@"drawObjectType" onObject:self];
	newLuaObjectOfMenuItem(g_L, item);
	
	lua_call(g_L, 2, 0);
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
