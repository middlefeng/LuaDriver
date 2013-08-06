//
//  LDMainWindow.m
//  LuaDriver
//
//  Created by Middleware on 7/12/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDMainWindow.h"
#import "LDUtilities.h"
#import "LDOpenGLView.h"



#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



extern lua_State* g_L;
const char* k_userData;



static int ld_main_window_set_title(lua_State* L);
static int ld_main_window_make_key_and_order_front(lua_State* L);
static int ld_main_window_get_opengl_view(lua_State* L);


static const luaL_Reg metatable[] = {
	{ "setTitle", ld_main_window_set_title },
	{ "makeKeyAndOrderFront", ld_main_window_make_key_and_order_front },
	{ "getOpenGLView", ld_main_window_get_opengl_view },
	{ NULL, NULL },
};



@implementation LDMainWindow




- (id) initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
		_userDataRef = 0;
	return self;
}




- (id) initWithContentRect:(NSRect)contentRect
				 styleMask:(NSUInteger)aStyle
				   backing:(NSBackingStoreType)bufferingType
					 defer:(BOOL)flag
{
	self = [super initWithContentRect:contentRect styleMask:aStyle
							  backing:bufferingType defer:flag];
	return self;
}




- (void) createUserdata:(lua_State*)L
{
	if (_userDataRef)
		return;

	_userDataRef = [LDUtilities newLuaObject:L fromObject:self];
	
	[LDUtilities prepMetatable:L name:@"LDMainWindow"];
	lua_getglobal(L, "LDMainWindow");
	luaL_setfuncs(L, metatable, 0);		/* add file methods to new metatable */
	lua_setmetatable(L, -2);
	
	lua_pop(L, 2);
}




- (void) dealloc
{
	if (_userDataRef)
		luaL_unref(g_L, LUA_REGISTRYINDEX, _userDataRef);
	[super dealloc];
}




static int ld_main_window_set_title(lua_State* L)
{
	lua_getfield(L, 1, k_userData);
	LDMainWindow** window = (LDMainWindow**)lua_touserdata(L, -1);
	lua_pop(L, 1);
	
	const char* title = lua_tostring(L, 2);
	[*window setTitle:[NSString stringWithUTF8String:title]];
	lua_pop(L, 1);

	return 0;
}




static int ld_main_window_make_key_and_order_front(lua_State* L)
{
	LDMainWindow* window  = [LDUtilities userDataFromLuaTable:L atIndex:1];
	id sender = nil;
	if (lua_gettop(L) == 2 && lua_istable(L, 2))
		[LDUtilities userDataFromLuaTable:L atIndex:2];
	
	[window makeKeyAndOrderFront:sender];
	[[window openGLView] becomeFirstResponder];
	lua_pop(L, lua_gettop(L));
	return 0;
}




static int ld_main_window_get_opengl_view(lua_State* L)
{
	LDMainWindow* window = [LDUtilities userDataFromLuaTable:L atIndex:1];
	LDOpenGLView* view = [window openGLView];
	[view createUserData:L];
	lua_rawgeti(L, LUA_REGISTRYINDEX, (int)[view userDataRef]);
	return 1;
}




@end
