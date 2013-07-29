//
//  LDApplication.m
//  LuaDriver
//
//  Created by Middleware on 7/29/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDApplication.h"

#import "LDUtilities.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



extern const char* k_userData;



static const luaL_Reg LDApplicationMetaFuncs[] = {
	{ NULL, NULL }
};



extern void newLuaObjectOfApplication(struct lua_State* L, NSApplication* app)
{
	lua_newtable(L);
	NSApplication** ldapp = lua_newuserdata(L, sizeof(NSApplication*));
	*ldapp = [app retain];
	lua_setfield(L, -2, k_userData);

	[LDUtilities newMetatable:L name:@"LDApplication"];
	luaL_setfuncs(L, LDApplicationMetaFuncs, 0);
	lua_setmetatable(L, -2);
}