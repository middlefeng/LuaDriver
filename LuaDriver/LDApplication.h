//
//  LDApplication.h
//  LuaDriver
//
//  Created by Middleware on 7/29/13.
//  Copyright (c) 2013 Dong. All rights reserved.
//

#import <Foundation/Foundation.h>



struct lua_State;



extern void init_LDApplication(struct lua_State* L);



extern void newLuaObjectOfApplication(struct lua_State* L, NSApplication* app);