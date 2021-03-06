//
//  LDAppDelegate.m
//  LuaDriver
//
//  Created by Middleware on 7/12/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//


#import "LDAppDelegate.h"
#import "LDUtilities.h"

#import "LDMainWindow.h"
#import "LDApplication.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"




extern lua_State* g_L;
extern const char* k_userData;



static int app_delegate_main_window(lua_State* L);



static const luaL_Reg metatable[] = {
	{ "getMainWindow", app_delegate_main_window },
	{ NULL, NULL },
};




@implementation LDAppDelegate




- (id) init
{
	self = [super init];
	if (self)
		_userDataRef = 0;
	return self;
}




- (void)dealloc
{
	if (_userDataRef)
		luaL_unref(g_L, LUA_REGISTRYINDEX, _userDataRef);
    [super dealloc];
}




- (void) createUserData:(struct lua_State*)L
{
	if (_userDataRef)
		return;
	
	_userDataRef = [LDUtilities newLuaObject:L fromObject:self];
	
	[LDUtilities prepMetatable:L name:@"LDAppDelegate"];
	lua_getglobal(L, "LDAppDelegate");
	luaL_setfuncs(L, metatable, 0);
	lua_setmetatable(L, -2);
	
	lua_pop(L, 2);
}




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	[self createUserData:g_L];
	[LDUtilities prepCall:g_L onMethod:@"applicationDidFinishLaunching"
				 onObject:self];
	lua_call(g_L, 1, 0);
}




- (BOOL)applicationShouldHandleReopen:(NSApplication*)theApp
					hasVisibleWindows:(BOOL)flag
{
	[self createUserData:g_L];
	[LDUtilities prepCall:g_L onMethod:@"applicationShouldHandleReopen"
				 onObject:self];
	newLuaObjectOfApplication(g_L, theApp);
	lua_pushboolean(g_L, flag);
	lua_call(g_L, 3, 0);
	
	bool result = lua_toboolean(g_L, -1);
	lua_pop(g_L, 1);
	
	return result;
}



- (void)applicationWillTerminate:(NSNotification *)aNotification
{
	[self createUserData:g_L];
	[LDUtilities prepCall:g_L onMethod:@"applicationWillTerminate"
				 onObject:self];
	lua_call(g_L, 1, 0);
}





static int app_delegate_main_window(lua_State* L)
{
	LDAppDelegate* delegate = [LDUtilities userDataFromLuaTable:L atIndex:1];
	[[delegate window] createUserdata:L];
	lua_rawgeti(L, LUA_REGISTRYINDEX, [[delegate window] userDataRef]);
	
	return 1;
}



@end
