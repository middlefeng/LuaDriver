//
//  LDNSEvent.h
//  LuaDriver
//
//  Created by Middleware on 7/26/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//



#import <Foundation/Foundation.h>



struct lua_State;


extern void init_LDEvent(struct lua_State* L);
extern void newLuaObjectOfEvent(struct lua_State* L, NSEvent* event);