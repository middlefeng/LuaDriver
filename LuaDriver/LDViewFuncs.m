//
//  LDViewFuncs.m
//  LuaDriver
//
//  Created by Middleware on 7/22/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import "LDViewFuncs.h"
#import "LDUtilities.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



extern int ld_view_get_frame(struct lua_State* L)
{
	NSView* view = [LDUtilities userDataFromLuaTable:L atIndex:1];
	lua_pop(L, 1);
	
	[LDUtilities newLuaObject:L fromRect:[view frame]];
	return 1;
}




extern int ld_view_set_needs_display(struct lua_State* L)
{
	NSView* view = [LDUtilities userDataFromLuaTable:L atIndex:1];
	bool needs = lua_toboolean(L, 2);
	lua_pop(L, 2);
	
	[view setNeedsDisplay:needs];
	
	return 0;
}