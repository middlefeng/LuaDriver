//
//  LDOpenPanel.m
//  LuaDriver
//
//  Created by Middleware on 7/29/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDOpenPanel.h"
#import "LDUtilities.h"
#import "LDURL.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



static int ld_open_save_panel_begin_sheet_modal_for_window(lua_State* L);

static int ld_open_panel_get(lua_State* L);
static int ld_open_panel_set_allow_multiple_selection(lua_State* L);
static int ld_open_panel_get_urls(lua_State* L);



extern const char* k_userData;



static const struct luaL_Reg LDOpenPanelFuncs[] = {
	{ "getOpenPanel", ld_open_panel_get },
	{ NULL, NULL },
};




static const struct luaL_Reg LDOpenPanelMetaFuncs[] = {
	{ "beginSheetModalForWindow", ld_open_save_panel_begin_sheet_modal_for_window },
	{ "setAllowsMultipleSelection", ld_open_panel_set_allow_multiple_selection },
	{ "getURLs", ld_open_panel_get_urls },
	{ NULL, NULL },
};



extern void init_LDOpenPanel(struct lua_State* L)
{
	lua_newtable(L);
	lua_pushvalue(L, -1);
	lua_setglobal(L, "NSOpenPanel");
	luaL_setfuncs(L, LDOpenPanelFuncs, 0);
	lua_pop(L, 1);
}





static int ld_open_panel_get(lua_State* L)
{
	lua_newtable(L);
	
	NSOpenPanel** panel = lua_newuserdata(L, sizeof(NSOpenPanel*));
	*panel = [[NSOpenPanel openPanel] retain];
	lua_setfield(L, -2, k_userData);
	
	[LDUtilities newMetatable:L name:@"LDOpenPanelMeta"];
	luaL_setfuncs(L, LDOpenPanelMetaFuncs, 0);
	lua_setmetatable(L, -2);
	
	return 1;
}




static int ld_open_save_panel_begin_sheet_modal_for_window(lua_State* L)
{
	NSSavePanel* panel = [LDUtilities userDataFromLuaTable:L atIndex:1];
	NSWindow* window = [LDUtilities userDataFromLuaTable:L atIndex:2];
	
	int handler = 0;
	if (lua_gettop(L) == 3)
		handler = luaL_ref(L, LUA_REGISTRYINDEX);
	
	void (^completeHandler)(NSInteger) = nil;
	if (handler) {
		completeHandler = ^void (NSInteger i) {
			lua_rawgeti(L, LUA_REGISTRYINDEX, handler);
			luaL_unref(L, LUA_REGISTRYINDEX, handler);
			lua_pushinteger(L, i);
			lua_call(L, 1, 0);
		};
	}
	
	[panel beginSheetModalForWindow:window completionHandler:completeHandler];
	lua_pop(L, 2);
	return 0;
}



static int ld_open_panel_set_allow_multiple_selection(lua_State* L)
{
	NSOpenPanel* panel = [LDUtilities userDataFromLuaTable:L atIndex:1];
	BOOL allow = lua_toboolean(L, 2);
	lua_pop(L, 2);
	
	[panel setAllowsMultipleSelection:allow];
	return 0;
}




static int ld_open_panel_get_urls(lua_State* L)
{
	NSOpenPanel* panel = [LDUtilities userDataFromLuaTable:L atIndex:1];
	lua_pop(L, 1);
	
	NSArray* urls = [panel URLs];
	for (NSUInteger i = 0; i < [urls count]; ++i) {
		NSURL* current = [urls objectAtIndex:i];
		newLuaObjectOfURL(L, current);
	}
	
	return (int)[urls count];
}






