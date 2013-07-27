//
//  LDMenu.m
//  LuaDriver
//
//  Created by Middleware on 7/27/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//


#import "LDMenu.h"

#import "LDUtilities.h"


#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



extern const char* k_userData;



static int ld_menu_get_items(lua_State* L);


static int ld_menu_item_set_state(lua_State* L);
static int ld_menu_item_get_state(lua_State* L);
static int ld_menu_item_get_title(lua_State* L);
static int ld_menu_item_get_menu(lua_State* L);




static const struct luaL_Reg LDMenuMetaFuncs[] = {
	{ "getItems", ld_menu_get_items },
	{ NULL, NULL },
};



static const struct luaL_Reg LDMenuItemMetaFuncs[] = {
	{ "setState", ld_menu_item_set_state },
	{ "getState", ld_menu_item_get_state },
	{ "getTitle", ld_menu_item_get_title },
	{ "getMenu", ld_menu_item_get_menu },
	{ NULL, NULL },
};




extern void init_LDMenu(struct lua_State* L)
{
}




extern void newLuaObjectOfMenu(struct lua_State* L, NSMenu* menu)
{
	lua_newtable(L);
	NSMenu** ldmenu = lua_newuserdata(L, sizeof(NSMenu*));
	*ldmenu = [menu retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDMenu" gcmt:ld_nsobject_release_gc];
	luaL_setfuncs(L, LDMenuMetaFuncs, 0);
	lua_setmetatable(L, -2);
}




static int ld_menu_get_items(lua_State* L)
{
	NSMenu* menu = [LDUtilities userDataFromLuaTable:L atIndex:1];
	lua_pop(L, 1);
	
	NSArray* items = [menu itemArray];
	lua_newtable(L);
	
	for (NSUInteger i = 0; i < [items count]; ++i) {
		NSMenuItem* item = [items objectAtIndex:i];
		newLuaObjectOfMenuItem(L, item);
		lua_rawseti(L, -2, (int)(i + 1));
	}
	
	return 1;
}



extern void newLuaObjectOfMenuItem(struct lua_State* L, NSMenuItem* item)
{
	lua_newtable(L);
	NSMenuItem** lditem = lua_newuserdata(L, sizeof(NSMenuItem*));
	*lditem = [item retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDMenuItem" gcmt:ld_nsobject_release_gc];
	luaL_setfuncs(L, LDMenuItemMetaFuncs, 0);
	lua_setmetatable(L, -2);
}



static int ld_menu_item_set_state(lua_State* L)
{
	NSMenuItem* item = [LDUtilities userDataFromLuaTable:L atIndex:1];
	const char* stateName = luaL_checkstring(L, 2);
	
	NSInteger state = 0;
	if (strcmp(stateName, "NSOnState") == 0)
		state = NSOnState;
	else if (strcmp(stateName, "NSOffState") == 0)
		state = NSOffState;
	else
		state = NSMixedState;
	
	lua_pop(L, 2);
	[item setState:state];
	return 0;
}



static int ld_menu_item_get_state(lua_State* L)
{
	NSMenuItem* item = [LDUtilities userDataFromLuaTable:L atIndex:1];
	lua_pop(L, 1);
	
	if ([item state] == NSOnState)
		lua_pushstring(L, "NSOnState");
	else if ([item state] == NSOffState)
		lua_pushstring(L, "NSOffState");
	else
		lua_pushstring(L, "NSMixedState");
	
	return 1;
}



static int ld_menu_item_get_title(lua_State* L)
{
	NSMenuItem* item = [LDUtilities userDataFromLuaTable:L atIndex:1];
	lua_pop(L, 1);
	
	NSString* title = [item title];
	lua_pushstring(L, [title UTF8String]);
	return 1;
}




static int ld_menu_item_get_menu(lua_State* L)
{
	NSMenuItem* item = [LDUtilities userDataFromLuaTable:L atIndex:1];
	NSMenu* menu = [item menu];
	
	newLuaObjectOfMenu(L, menu);
	return 1;
}






