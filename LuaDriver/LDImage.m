//
//  LDImage.m
//  LuaDriver
//
//  Created by Feng,Dong on 7/29/13.
//  Copyright (c) 2013 Feng,Dong. All rights reserved.
//

#import "LDImage.h"

#import "LDUtilities.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



const char* k_userData;


static int ld_image_new_with_contents_of_file(lua_State* L);
static int ld_image_new_with_size(lua_State* L);


static int ld_image_get_size(lua_State* L);



static const luaL_Reg LDImageFuncs[] = {
	{ "newWithContentsOfFile", ld_image_new_with_contents_of_file },
	{ "newWithSize", ld_image_new_with_size },
	{ NULL, NULL },
};



static const luaL_Reg LDImageMetaFuncs[] = {
	{ "getSize", ld_image_get_size },
	{ NULL, NULL }
};



void init_LDImage(struct lua_State* L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "NSImage");
	luaL_setfuncs(L, LDImageFuncs, 0);
	lua_pop(L, 1);
}



static int ld_image_new_with_contents_of_file(lua_State* L)
{
	const char* filePath = luaL_checkstring(L, 1);
	
	lua_newtable(L);
	NSImage** image = lua_newuserdata(L, sizeof(NSImage*));
	*image = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:filePath]];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDImageMeta"];
	luaL_setfuncs(L, LDImageMetaFuncs, 0);
	lua_setmetatable(L, -2);
	
	return 1;
}



static int ld_image_new_with_size(lua_State* L)
{
	lua_getfield(L, 1, "width");
	lua_getfield(L, 1, "height");
	float w = luaL_checknumber(L, -2);
	float h = luaL_checknumber(L, -1);
	lua_pop(L, 3);
	
	lua_newtable(L);
	NSImage** image = lua_newuserdata(L, sizeof(NSImage*));
	*image = [[NSImage alloc] initWithSize:NSMakeSize(w, h)];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDImageMeta"];
	luaL_setfuncs(L, LDImageMetaFuncs, 0);
	lua_setmetatable(L, -2);
	
	return 1;
}



static int ld_image_get_size(lua_State* L)
{
	NSImage* ldimage = [LDUtilities userDataFromLuaTable:L atIndex:1];
	lua_pop(L, 1);
	
	NSBitmapImageRep* rep = [[ldimage representations] objectAtIndex:0];
	NSSize size = [rep size];
	[LDUtilities newLuaObject:L fromRect:NSMakeRect(0, 0, size.width, size.height)];
	return 1;
}








