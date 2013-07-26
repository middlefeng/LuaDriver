//
//  LDScreen.m
//  LuaDriver
//
//  Created by Middleware on 7/16/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import "LDScreen.h"
#import "LDUtilities.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"




extern const char* k_userData;




static int ld_get_main_screen(lua_State* L);


static int ld_screen_gc(lua_State* L);
static int ld_screen_get_frame(lua_State* L);




static const struct luaL_Reg LDScreenFuncs[] = {
	{ "getMainScreen", ld_get_main_screen },
	{ NULL, NULL },
};



static const struct luaL_Reg LDScreenMetatable[] = {
	{ "getFrame", ld_screen_get_frame },
	{ NULL, NULL },	
};




void init_LDScreen(lua_State* L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "NSScreen");
	luaL_setfuncs(L, LDScreenFuncs, 0);
	lua_pop(L, 1);
}




static int ld_get_main_screen(lua_State* L)
{
	lua_newtable(L);
	NSScreen** ldscreen = (NSScreen**)lua_newuserdata(L, sizeof(NSScreen*));
	*ldscreen = [[NSScreen mainScreen] retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDScreen" gcmt:ld_screen_gc];
	luaL_setfuncs(L, LDScreenMetatable, 0);
	lua_setmetatable(L, -2);
	
	return 1;
}




static int ld_screen_gc(lua_State* L)
{
	lua_getfield(L, 1, k_userData);
	NSScreen** screen = (NSScreen**)lua_touserdata(L, -1);
	[*screen release];
	lua_pop(L, 2);
	
	return 0;
}




static int ld_screen_get_frame(lua_State* L)
{
	lua_getfield(L, 1, k_userData);
	NSScreen** screen = (NSScreen**)lua_touserdata(L, -1);
	NSRect result = [*screen frame];
	lua_pop(L, 2);
	
	[LDUtilities newLuaObject:L fromRect:result];
	return 1;
}



