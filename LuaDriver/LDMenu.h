//
//  LDMenu.h
//  LuaDriver
//
//  Created by Middleware on 7/27/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import <Foundation/Foundation.h>



struct lua_State;


extern void init_LDMenu(struct lua_State* L);

extern void newLuaObjectOfMenu(struct lua_State* L, NSMenu* menu);
extern void newLuaObjectOfMenuItem(struct lua_State* L, NSMenuItem* item);