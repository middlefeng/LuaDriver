//
//  LDBundle.m
//  LuaDriver
//
//  Created by Middleware on 7/20/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import "LDBundle.h"
#import "LDUtilities.h"


#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"




extern const char* k_userData;




static int ld_get_main_bundle(lua_State* L);


static int ld_bundle_gc(lua_State* L);
static int ld_bundle_path_for_resource(lua_State* L);




static const struct luaL_Reg LDBundleFuncs[] = {
	{ "getMainBundle", ld_get_main_bundle },
	{ NULL, NULL },
};



static const struct luaL_Reg LDBundleMetatable[] = {
	{ "__gc", ld_bundle_gc },
	{ "pathForResource", ld_bundle_path_for_resource },
	{ NULL, NULL },
};




extern void init_LDBundle(struct lua_State* L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "NSBundle");
	luaL_setfuncs(L, LDBundleFuncs, 0);
	lua_pop(L, 1);
}




static int ld_get_main_bundle(lua_State* L)
{
	lua_newtable(L);
	NSBundle** ldbundle = (NSBundle**)lua_newuserdata(L, sizeof(NSBundle*));
	*ldbundle = [[NSBundle mainBundle] retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDBundle" gcmt:ld_bundle_gc];
	luaL_setfuncs(L, LDBundleMetatable, 0);
	lua_setmetatable(L, -2);
	
	return 1;
}




static int ld_bundle_gc(lua_State* L)
{
	lua_getfield(L, 1, k_userData);
	NSBundle** bundle = (NSBundle**)lua_touserdata(L, -1);
	[*bundle release];
	lua_pop(L, 2);
	
	return 0;
}




static int ld_bundle_path_for_resource(lua_State* L)
{
	NSBundle* bundle = [LDUtilities userDataFromLuaTable:L atIndex:1];
	const char* name = lua_tostring(L, 2);
	const char* type = NULL;
	
	if (lua_gettop(L) > 2)
		type = lua_tostring(L, 3);
	
	NSString* typeStr = type ? [NSString stringWithUTF8String:type] : nil;
	NSString* path = [bundle pathForResource:[NSString stringWithUTF8String:name]
									  ofType:typeStr];
	
	lua_pop(L, lua_gettop(L));
	lua_pushstring(L, [path UTF8String]);
	return 1;
}







