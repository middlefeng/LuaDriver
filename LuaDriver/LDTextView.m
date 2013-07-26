//
//  LDTextView.m
//  LuaDriver
//
//  Created by Middleware on 7/17/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//


#import "LDTextView.h"
#import "LDUtilities.h"

#import "lua.h"
#import "lualib.h"
#import "lauxlib.h"



extern const char* k_userData;
extern struct lua_State* g_L;



static int ld_text_view_super_draw_rect(lua_State* L);



static const luaL_Reg LDTextViewMetatable[] = {
	{ "superDrawRect", ld_text_view_super_draw_rect },
	{ NULL, NULL },
};




@implementation LDTextView




- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	return self;
}




- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    return self;
}





- (void)drawRect:(NSRect)dirtyRect
{
	[self createUserData:g_L];

	lua_rawgeti(g_L, LUA_REGISTRYINDEX, _userDataRef);

	lua_getglobal(g_L, "LDTextView");
	lua_getfield(g_L, -1, "drawRect");					// funcs
	lua_remove(g_L, -2);
	lua_pushvalue(g_L, -2);								// "this"
	[LDUtilities newLuaObject:g_L fromRect:dirtyRect];  // rect
	
	lua_pcall(g_L, 2, 0, 0);
}





- (void)superDrawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
}




- (void) createUserData:(struct lua_State*)L
{
	if (_userDataRef)
		return;
	
	_userDataRef = [LDUtilities newLuaObject:L fromObject:self];
	
	[LDUtilities prepMetatable:L name:@"LDTextView" gcmt:nil];
	
	lua_getglobal(L, "LDTextView");
	luaL_setfuncs(L, LDTextViewMetatable, 0);
	lua_setmetatable(L, -2);
	
	lua_pop(L, 2);
}




static int ld_text_view_super_draw_rect(lua_State* L)
{
	LDTextView* textView = [LDUtilities userDataFromLuaTable:L atIndex:1];
	NSRect rect = [LDUtilities nsRectFromLuaObject:L atIndex:2];
	lua_pop(L, 2);
	
	[textView superDrawRect:rect];
	
	return 0;
}




@end
