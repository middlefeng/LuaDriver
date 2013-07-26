//
//  LDNSEvent.m
//  LuaDriver
//
//  Created by Middleware on 7/26/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDEvent.h"

#import "LDUtilities.h"


#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



extern const char* k_userData;




static int ld_event_get_characters(lua_State* L);





static const struct luaL_Reg LDEventMetaFuncs[] = {
	{ "getCharacters", ld_event_get_characters },
	{ NULL, NULL },
};




extern void init_LDEvent(struct lua_State* L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "NSEvent");
	luaL_setfuncs(L, LDEventMetaFuncs, 0);
	lua_pop(L, 1);
}



extern void newLuaObjectOfEvent(struct lua_State* L, NSEvent* event)
{
	lua_newtable(L);
	NSEvent** ldevent = lua_newuserdata(L, sizeof(NSEvent*));
	*ldevent = [event retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDEvent" gcmt:ld_nsobject_release_gc];
	luaL_setfuncs(L, LDEventMetaFuncs, 0);
	lua_setmetatable(L, -2);
}




static int ld_event_get_characters(lua_State* L)
{
	NSEvent* event = [LDUtilities userDataFromLuaTable:L atIndex:1];
	NSString* characters = [event characters];
	lua_pop(L, 1);
	lua_pushstring(L, [characters UTF8String]);
	return 1;
}


