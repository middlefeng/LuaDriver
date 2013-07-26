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




- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSString* luaSrcName = @"LuaAppDelegate";
	NSString* luaSrcPath = [LDUtilities luaSourcePath:luaSrcName];
	if (luaL_loadfile(g_L, [luaSrcPath UTF8String]) != LUA_OK) {
		[LDUtilities error:@"Failed to load file %@.", luaSrcName];
		return;
	}
	
	[self createUserData:g_L];
	lua_rawgeti(g_L, LUA_REGISTRYINDEX, _userDataRef);
	
	int result = lua_pcall(g_L, 1, 0, 0);
	if (result != LUA_OK) {
		const char* error = "unknown";
		if (lua_isstring(g_L, -1)) {
			error = lua_tostring(g_L, -1);
		}
		
		NSString* nsError = [NSString stringWithFormat:@"Failed to run file:%@, Error: %s.",
								luaSrcName, error];
		[LDUtilities error:nsError];
		lua_pop(g_L, 1);
	}
}




- (void) createUserData:(struct lua_State*)L
{
	if (_userDataRef)
		return;
	
	_userDataRef = [LDUtilities newLuaObject:L fromObject:self];
	[LDUtilities newMetatable:L name:@"LDAppDelegate" gcmt:nil];
	luaL_setfuncs(L, metatable, 0);
	
	lua_setmetatable(L, -2);
	lua_pop(L, 2);
}




static int app_delegate_main_window(lua_State* L)
{
	LDAppDelegate* delegate = [LDUtilities userDataFromLuaTable:L atIndex:1];
	[[delegate window] createUserdata:L];
	lua_rawgeti(L, LUA_REGISTRYINDEX, [[delegate window] userDataRef]);
	
	return 1;
}



@end
