//
//  LDFileManager.m
//  LuaDriver
//
//  Created by Middleware on 7/16/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import "LDFileManager.h"
#import "LDUtilities.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



const char* k_userData;



static int ld_file_manager_get_home_directory(lua_State* L);
static int ld_file_manager_get_default(lua_State* L);
static int ld_file_manager_is_file_exist(lua_State* L);
static int ld_file_manager_create_directory(lua_State* L);





static const luaL_Reg LDFileManager[] = {
	{ "getHomeDirectory", ld_file_manager_get_home_directory },
	{ "getDefault", ld_file_manager_get_default },
	{ NULL, NULL },
};




static const luaL_Reg LDFileManagerMetatable[] = {
	{ "isFileExist", ld_file_manager_is_file_exist },
	{ "createDirectory", ld_file_manager_create_directory },
	{ NULL, NULL },	
};




void init_LDFileManager(struct lua_State* L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "NSFileManager");
	luaL_setfuncs(L, LDFileManager, 0);
	lua_pop(L, 1);
}




static int ld_file_manager_get_home_directory(lua_State* L)
{
	NSString* home = NSHomeDirectory();
	lua_pushstring(L, [home UTF8String]);
	return 1;
}




static int ld_file_manager_get_default(lua_State* L)
{
	lua_newtable(L);
	
	NSFileManager** manager = lua_newuserdata(L, sizeof(NSFileManager*));
	*manager = [[NSFileManager defaultManager] retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDFileManager"
						 gcmt:ld_nsobject_release_gc];
	luaL_setfuncs(L, LDFileManagerMetatable, 0);
	lua_setmetatable(L, -2);
	
	return 1;
}




static int ld_file_manager_is_file_exist(lua_State* L)
{
	NSFileManager* manager = [LDUtilities userDataFromLuaTable:L atIndex:1];
	const char* path = lua_tostring(L, 2);
	
	BOOL isDir;
	BOOL r = [manager fileExistsAtPath:[NSString stringWithUTF8String:path]
						   isDirectory:&isDir];
	
	lua_pop(L, 2);
	lua_pushboolean(L, r);
	lua_pushboolean(L, isDir);
	
	return 2;
}




static int ld_file_manager_create_directory(lua_State* L)
{
	NSFileManager* manager = [LDUtilities userDataFromLuaTable:L atIndex:1];
	const char* path = lua_tostring(L, 2);
	NSError* err;
	
	[manager createDirectoryAtURL:[NSURL fileURLWithPath:[NSString stringWithUTF8String:path]]
				withIntermediateDirectories:YES attributes:nil error:&err];
	
	lua_pop(L, 2);
	if (err) {
		lua_pushboolean(L, false);
		lua_pushstring(L, [[err localizedDescription] UTF8String]);
		return 2;
	}
	
	lua_pushboolean(L, true);
	return 1;
}







