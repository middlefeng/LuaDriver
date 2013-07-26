//
//  LDUtilities.m
//  LuaDriver
//
//  Created by Middleware on 7/12/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import "LDUtilities.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"




extern const char* k_userData;
extern lua_State* g_L;




@implementation LDUtilities





+ (BOOL) initializeLDClass:(NSString*)className
{
	NSString* luaSrcName = className;
	NSString* luaSrcPath = [LDUtilities luaSourcePath:luaSrcName];
	if (luaL_loadfile(g_L, [luaSrcPath UTF8String]) != LUA_OK) {
		const char* error = "unknown";
		if (lua_isstring(g_L, -1))
			error = lua_tostring(g_L, -1);

		[LDUtilities error:@"Failed to load file %@, Error: %s.", luaSrcName, error];
		lua_pop(g_L, 1);
		return NO;
	}
	
	int result = lua_pcall(g_L, 0, 0, 0);
	if (result != LUA_OK) {
		const char* error = "unknown";
		if (lua_isstring(g_L, -1))
			error = lua_tostring(g_L, -1);

		[LDUtilities error:@"Failed to run file:%@, Error: %s", luaSrcName, error];
		lua_pop(g_L, 1);
		return NO;
	}
	
	return YES;
}




+ (NSString*) luaSourcePath:(NSString*)name
{
	return [[NSBundle mainBundle] pathForResource:name ofType:@"lua"];
}




+ (void) error:(NSString*)errorText, ...
{
	va_list(ap);
	va_start(ap, errorText);
	NSString* errorState = [[NSString alloc] initWithFormat:errorText arguments:ap];
	va_end(ap);
	
	NSAlert* alert = [NSAlert alertWithMessageText:errorState
									 defaultButton:@"Terminate"
								   alternateButton:nil
									   otherButton:nil
						 informativeTextWithFormat:@""];
	[alert setAlertStyle:NSCriticalAlertStyle];
	[alert runModal];
}




+ (int) luaTableKeyCount:(struct lua_State*)L at:(int)index
{
	int count = 0;
	lua_pushnil(L);
	
	if (index < 0)
		--index;
	
	while (lua_next(L, index) != 0) {
		++count;
		lua_pop(L, 1);
	}
	return count;
}




+ (void) newLuaObject:(struct lua_State*)L fromRect:(NSRect)rect;
{
	lua_newtable(L);
	
	lua_pushnumber(L, rect.origin.x);
	lua_setfield(L, -2, "x");
	
	lua_pushnumber(L, rect.origin.y);
	lua_setfield(L, -2, "y");
	
	lua_pushnumber(L, rect.size.width);
	lua_setfield(L, -2, "width");
	
	lua_pushnumber(L, rect.size.height);
	lua_setfield(L, -2, "height");
}




+ (NSRect) nsRectFromLuaObject:(struct lua_State*)L atIndex:(int)index
{
	lua_Number x, y, w, h;
	
	lua_getfield(L, index, "x");
	lua_getfield(L, index, "y");
	lua_getfield(L, index, "width");
	lua_getfield(L, index, "height");
	h = lua_tonumber(L, -1);
	w = lua_tonumber(L, -2);
	y = lua_tonumber(L, -3);
	x = lua_tonumber(L, -4);
	lua_pop(L, 4);
	
	return NSMakeRect(x, y, w, h);
}




+ (void) commonGC:(struct lua_State*)L
{
	NSObject* o = [LDUtilities userDataFromLuaTable:L atIndex:-1];
	[o release];
	lua_pop(L, 1);
}




+ (void) newMetatable:(struct lua_State*)L name:(NSString*)name
				 gcmt:(lua_CFunction)gcmt;
{
	luaL_newmetatable(L, [name UTF8String]);
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	if (gcmt) {
		lua_pushcfunction(L, gcmt);
		lua_setfield(L, -2, "__gc");
	}
}




+ (void) prepMetatable:(struct lua_State*)L name:(NSString*)name
				  gcmt:(lua_CFunction)gcmt
{
	lua_getglobal(L, [name UTF8String]);
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");
	if (gcmt) {
		lua_pushcfunction(L, gcmt);
		lua_setfield(L, -2, "__gc");
	}
	lua_pop(L, 1);
}





+ (int) newLuaObject:(struct lua_State*)L fromObject:(id)obj
{
	id* userData = lua_newuserdata(L, sizeof(id*));
	*userData = obj;
	
	lua_newtable(L);
	lua_pushvalue(L, -2);
	lua_setfield(L, -2, k_userData);
	lua_pushvalue(L, -1);

	return luaL_ref(L, LUA_REGISTRYINDEX);
}




+ (id) userDataFromLuaTable:(struct lua_State*)L atIndex:(int)index
{
	lua_getfield(L, index, k_userData);
	NSObject** o = lua_touserdata(L, -1);
	NSObject* r = *o;
	lua_pop(L, 1);
	
	return r;
}




@end




