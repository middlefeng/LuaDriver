//
//  LDURL.m
//  LuaDriver
//
//  Created by Middleware on 7/30/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDURL.h"

#import "LDUtilities.h"



#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"




extern const char* k_userData;


static int ld_url_get_path(lua_State* L);




static const struct luaL_Reg LDURLMetaFuncs[] = {
	{ "getPath", ld_url_get_path },
	{ NULL, NULL },
};




extern void newLuaObjectOfURL(struct lua_State* L, NSURL* url)
{
	lua_newtable(L);
	NSURL** ldurl = lua_newuserdata(L, sizeof(NSURL*));
	*ldurl = [url retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDURL"];
	luaL_setfuncs(L, LDURLMetaFuncs, 0);
	lua_setmetatable(L, -2);
}



static int ld_url_get_path(lua_State* L)
{
	NSURL* url = [LDUtilities userDataFromLuaTable:L atIndex:1];
	lua_pop(L, 1);
	
	lua_pushstring(L, [[url path] UTF8String]);
	return 1;
}






